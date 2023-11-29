#include<stdio.h>
void main()
{
    int num,fact1;
    printf("enter the number");
    scanf("%d",&num);
    fact1=fact(num);
    printf("factorial=%d",fact1);
}
int fact(int n)
{
    if(n==1)
    return 1;
    else
    return (n*n)+fact(n-1);
}
