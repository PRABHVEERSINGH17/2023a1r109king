#include<stdio.h>
void display(int);
void main()
{
    int limit;
    printf("enter the limit to print the natural number:");
    scanf("%d",&limit);
    display(limit);
}
void display (int x)
{
    if(x<0)
   return;
    else 
    printf("%d\n",x);
     display(1-x);
    return;
    printf("\n%d\n",x);
}