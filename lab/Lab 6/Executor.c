#include <stdio.h>
#include <math.h>
typedef unsigned short int uint16_t;

typedef struct
{
    char opcode[4];
    char value[12];
} INST;

typedef struct
{
    short int pc;
    char rom[65536][16];
    int n, z, p;
    short int R[8];
} STAT;

short int USEXT(int n, char *offset)
{
    short int v = 0;
    int mul = 1;
    for (int i = n - 1; i >= 0; i--)
    {
        v += (*(offset + i) - '0') * mul;
        mul *= 2;
    }
    return v;
}

short int SEXT(int n, char *offset)
{
    short int v = 0;
    int mul = 1;
    if(*offset == '0')
    {
        for (int i = n - 1; i >= 0; i--)
        {
            v += (*(offset + i) - '0') * mul;
            mul *= 2;
        }
    }
    else
    {
        for(int i = n - 1; i>=0; i--)
        {
            if(*(offset + i) == '0')
            {
                v -= mul;
            }
            mul *= 2;
        }
        v -= 1;
    }
    v = v % 65536;
    return v;
}

void SetCondition(STAT *stat, short int value)
{
    stat->n = 0;
    stat->p = 0;
    stat->z = 0;
    if (value < 0)
    {
        stat->n = 1;
    }
    else if (value == 0)
    {
        stat->z = 1;
    }
    else
    {
        stat->p = 1;
    }
}

int GetRegister(char *ta)
{
    return (*ta - '0') * 4 + (*(ta + 1) - '0') * 2 + *(ta + 2) - '0';
}

void TransSys(short int num, int syst, int digit, char *str)
{
    char *r = str + digit - 1;
    char index[] = "0123456789ABCDEF";
    if(num >= 0)
    {
        while (num != 0)
        {
            *r = index[num % syst];
            r--;
            num /= syst;
        }
        while (r != str - 1)
        {
            *r = '0';
            r--;
        }
    }
    else
    {
        unsigned short int nnum = 65536 + num;
        while (nnum != 0)
        {
            *r = index[nnum % syst];
            r--;
            nnum /= syst;
        }
        while (r != str - 1)
        {
            *r = '0';
            r--;
        }

    }
}

void BR(STAT *s, INST *inst)
{
    if ((s->n && (inst->value[0] - '0')) || (s->z && (inst->value[1] - '0')) || (s->p && (inst->value[2] - '0')))
    {
        s->pc += SEXT(9, (char *)(inst->value + 3));
    }
}

void ADD(INST *inst, STAT *stat)
{
    int DR = GetRegister((char *)inst->value);
    int SR1 = GetRegister((char *)inst->value + 3);
    short int value;
    // SR2
    if (inst->value[6] == '0')
    {
        int SR2 = GetRegister((char *)inst->value + 9);
        value = stat->R[SR1] + stat->R[SR2];
    }
    // imm5
    else
    {
        short int imm5 = SEXT(5, (char *)(inst->value + 7));
        value = imm5 + stat->R[SR1];
    }
    stat->R[DR] = value;
    SetCondition(stat, value);
}

void LD(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    short int _sext = SEXT(9, (char *)inst->value + 3);
    _sext += stat->pc;
    short int value = SEXT(16, stat->rom[(_sext + 65536) % 65536]);
    stat->R[DR] = value;
    SetCondition(stat, value);
}

void ST(STAT *stat, INST *inst)
{
    int SR = GetRegister((char *)inst->value);
    short int PCoffset = SEXT(9, (char *)inst->value + 3);
    TransSys(stat->R[SR], 2, 16, stat->rom[(stat->pc + PCoffset + 65536) % 65536]);
}

void JSR(STAT *stat, INST *inst)
{
    short int TEMP = stat->pc;
    if (inst->value[0] == '1')
    {
        short int PCoffset = SEXT(11, (char *)inst->value + 1);
        stat->pc += PCoffset;
    }
    else
    {
        int BaseR = GetRegister((char *)inst->value + 3);
        stat->pc = stat->R[BaseR];
    }
    stat->R[7] = TEMP;
}

void AND(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    int SR1 = GetRegister((char *)inst->value + 3);
    short int result;
    if (inst->value[6] == '0')
    {
        int SR2 = GetRegister((char *)inst->value + 9);
        result = stat->R[SR1] & stat->R[SR2];
    }
    else
    {
        short int PCoffset = SEXT(5, (char *)inst->value + 7);
        result = stat->R[SR1] & PCoffset;
    }
    stat->R[DR] = result;
    SetCondition(stat, result);
}

void LDR(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    int BaseR = GetRegister((char *)inst->value + 3);
    short int offset = SEXT(6, (char *)inst->value + 6);
    stat->R[DR] = SEXT(16, (char *)stat->rom[(stat->R[BaseR] + offset + 65536) % 65536]);
    SetCondition(stat, stat->R[DR]);
}

void STR(STAT *stat, INST *inst)
{
    int SR = GetRegister((char *)inst->value);
    int BaseR = GetRegister((char *)inst->value + 3);
    short int offset = SEXT(6, (char *)inst->value + 6);
    TransSys(stat->R[SR], 2, 16, (char *)stat->rom[(stat->R[BaseR] + offset + 65536) % 65536]);
}

void NOT(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    int SR = GetRegister((char *)inst->value + 3);
    short int val = ~stat->R[SR];
    stat->R[DR] = val;
    SetCondition(stat, val);
}

void LDI(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    short int PCoffset = SEXT(9, inst->value + 3);
    stat->R[DR] = SEXT(16, (char *)stat->rom[(SEXT(16, (char *)stat->rom[(stat->pc + PCoffset + 65536) % 65536]) + 65536) % 65536]);
    SetCondition(stat, stat->R[DR]);
}

void STI(STAT *stat, INST *inst)
{
    int SR = GetRegister((char *)inst->value);
    short int PCoffset = SEXT(9, (char *)inst->value + 3);
    TransSys(stat->R[SR], 2, 16, stat->rom[(SEXT(16, (char *)stat->rom[(stat->pc + PCoffset + 65536) % 65536]) + 65536) % 65536]);
}

void JMP(STAT *stat, INST *inst)
{
    int BaseR = GetRegister((char *)inst->value + 3);
    stat->pc = stat->R[BaseR];
}

void LEA(STAT *stat, INST *inst)
{
    int DR = GetRegister((char *)inst->value);
    short int PCoffset = SEXT(9, (char *)inst->value + 3);
    stat->R[DR] = stat->pc + PCoffset;
}

void TRAP(STAT *stat)
{
    for (int i = 0; i < 8; i++)
    {
        printf("R%d = x%04hX\n", i, stat->R[i]);
    }
}

void CPY(STAT *stat, int col, char *c)
{
    for (int i = 0; i < 16; i++)
    {
        int a = (col + 65536) % 65536;
        stat->rom[a][i] = *(c + i);
    }
}

void PST(STAT *stat, int col, INST *inst)
{
    for (int i = 0; i < 4; i++)
    {
        inst->opcode[i] = stat->rom[(col + 65536) % 65536][i];
    }
    for (int i = 0; i < 12; i++)
    {
        inst->value[i] = stat->rom[(col + 65536) % 65536][i + 4];
    }
}

void Initialize(STAT *stat)
{
    stat->n = 0;
    stat->z = 0;
    stat->p = 0;
    for (int i = 0; i < 8; i++)
    {
        stat->R[i] = 0x7777;
    }
    char value[17] = "0111011101110111";
    for (int i = 0; i < 65536; i++)
    {
        CPY(stat, i, value);
    }
    char ins[17] = "/0";
    gets(ins);
    short int loc = SEXT(16, ins);
    stat->pc = loc;
    int ch;
    int l = 0;
    while((ch = getchar()) != EOF)
    {
        if(ch >= 48 && ch <= 57)
        {
            if(l == 16)
            {
                loc++;
                l = 0;
                stat->rom[(loc + 65536) % 65536][l++] = ch;
            }
            else
            {
                stat->rom[(loc + 65536) % 65536][l++] = ch;
            }
        }
    }
}

int loop(STAT *stat)
{
    INST *inst = malloc(sizeof(INST) + 1);
    while (1)
    {
        PST(stat, (int)stat->pc, inst);
        stat->pc++;
        switch (USEXT(4, inst->opcode))
        {
        case 0:
        {
            BR(stat, inst);
            break;
        }
        case 1:
        {
            ADD(inst, stat);
            break;
        }
        case 2:
        {
            LD(stat, inst);
            break;
        }
        case 3:
        {
            ST(stat, inst);
            break;
        }
        case 4:
        {
            JSR(stat, inst);
            break;
        }
        case 5:
        {
            AND(stat, inst);
            break;
        }
        case 6:
        {
            LDR(stat, inst);
            break;
        }
        case 7:
        {
            STR(stat, inst);
            break;
        }
        case 9:
        {
            NOT(stat, inst);
            break;
        }
        case 10:
        {
            LDI(stat, inst);
            break;
        }
        case 11:
        {
            STI(stat, inst);
            break;
        }
        case 12:
        {
            JMP(stat, inst);
            break;
        }
        case 14:
        {
            LEA(stat, inst);
            break;
        }
        case 15:
        {
            if (USEXT(8, inst->value + 4) == 37)
            {
                TRAP(stat);
                return 0;
            }
            break;
        }
        default:
            printf("ERROR");
            break;
        }
    }
    free(inst);
}

int main()
{
    STAT stat;
    Initialize(&stat);
    loop(&stat);
    return 0;
}