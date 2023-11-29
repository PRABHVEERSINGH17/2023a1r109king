#include<stdio.h>
void main()
{
    int n;
    printf("enter the size of the array");
    scanf("%d",&n);
    int a[n],sum=0,sum1=0;
    printf("enter the arrayb elements");
    for(int i=0;i<n:i++)
    {
        scanf("%d",&a[i]);
        if(i%2==0)
        sum=sum+a[i];
        else
        sum1=sum1+a[i];
    }
    printf("sum pf even array elements =%d",sum);
    ptrintf("sum of odd array elements=%d",sum1);
}
