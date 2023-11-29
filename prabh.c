#include<stdio.h>
void main()
{
    char ch;
    printf("enter the character:");
    scanf("%c",&ch);
    if(ch=='a'||ch=='e'||ch=='i'||ch=='o'||ch=='u'||ch=='A'||ch=='E'||ch=='I'||ch=='O'||ch=='U')
    {
        printf("%c is vowel\n");}
        else
        {
            printf("%c is consonant\n");
        }
    
}