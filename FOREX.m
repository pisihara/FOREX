%% Auxiliary function FOREX()
%% This function computes the adjusted total period by period
%%
%% FUNCTION INPUTS
%% A0=initial units of currency A;  B0=initial units of currency B
%% data(:,1)=countryA CPI data;  data(:,2)=countryB CPI data; 
%% data(:,3)=listed exchange rate: 1 unit A currency = x units B currency
%% CM0 is the initial period (trading begins the enxt period
%% and will continue to the last period in data)
%% n is the number of most recent prior historical data periods used in CPI regression
%% spreadA = brokerage cost adjustment in exchanging A to B
%% spreadB = brokerage cost adjustment in exchanging B to A
%% fractionA = fraction of A which is exchanged
%% fractionB = fraction of B which is exchanged
%% R2Amin = threshold R^2 coefficient for CPI A regression
%% R2Bmin = threshold R^2 coefficient for CPI B regression

%% FUNCTION OUTPUTS (based on n periods used in regression)
%% TOTALA(i,1) = total gain/loss in period i (given in currency A) adjusted to initial period
%% TOTALB(i,1) = total gain/loss in period i (given in currency B) adjusted to initial period
%% NOEXA(i,1) = No exchange total gain/loss in period i (given in currency A) adjusted to initial period
%% NOEXB(i,1) = No exchange total gain/loss in period i (given in currency B) adjusted to initial period

%% A(i,1) = amount of A in period i
%% B(i,1) = amount of B in period i
%% R2A(i,1) = R^2 value in predicted CPIA in period i+1 
%% R2B(i,1) = R^2 value in predicted CPIB in period i+1
%% month(i,1) = historical period number corresponding to transaction period i

function [TOTALA,TOTALB,NOEXA,NOEXB,A,B,R2A,R2B,month]=FOREX(A0,B0,Data,CM0,n,spreadA,spreadB, fractionA, fractionB, R2Amin,R2Bmin)
 A(CM0,1)=A0;  B(CM0,1)=B0; %%Initial investments 
 month(CM0,1)=CM0;  %%Initial month
 %%Total Initial Amount in currency A 
 TOTALA(CM0,1)=0;
 TOTALB(CM0,1)=0;

for start=1: length(Data) - CM0      
CM=CM0+start;  %% Current Month
j=0;
for i=CM-n+1:CM-1 
 j=j+1;   
 XA(j,1)=Data(i-1,1); %%Actual CPI for Country A in period i-1
 XB(j,1)=Data(i-1,2); %%Actual CPI for Country B in period i-1
 YA(j,1)=Data(i,1); %%Actual CPI for Country A in period i
 YB(j,1)=Data(i,2); %%Actual CPI for Country B in period i
end
%Compute Regression Coefficients from historical data
Acoef=[ones(size(XA)) XA];
Bcoef=[ones(size(XB)) XB];
[a, aint, ar, arint, astats]= regress(YA,Acoef);
[b, bint, br, brint, bstats]= regress(YB,Bcoef);

%% R^2 values
R2A(CM,1)=astats(1,1);
R2B(CM,1)=bstats(1,1);

%%Forecast CPIA and CPIB for current month
CPIAF(CM,1)= a(1,1) + a(2,1)*Data(CM-1,1);
CPIBF(CM,1)= b(1,1) + b(2,1)*Data(CM-1,2);

%% Model Predicted Exchange Rate for Current Month.
AINF(CM,1)=(CPIAF(CM,1)-Data(CM-1,1))/Data(CM-1,1);
BINF(CM,1)=(CPIBF(CM,1)-Data(CM-1,2))/Data(CM-1,2);
d(CM,1)=AINF(CM,1)-BINF(CM,1);
SF(CM,1) = Data(CM-1,3)*(1+d(CM,1)); %%Predicted Exchange Rate

%%Currency Exchange
 if SF(CM,1) > (Data(CM,3) + spreadB) && R2A(CM,1)>R2Amin &&  R2B(CM,1)>R2Bmin  %%Opportunity to convert B to A
    convert = fractionB*B(CM-1,1);
    B(CM,1)=B(CM-1,1) - convert;
    A(CM,1)=A(CM-1,1)+ convert/(Data(CM,3) + spreadB);
   elseif  SF(CM,1) < Data(CM,3)-spreadA && R2A(CM,1)>R2Amin && R2B(CM,1)>R2Bmin   %%Opporunity to convert A to B
    convert = fractionA*A(CM-1,1);
    A(CM,1)=A(CM-1,1) - convert;
    B(CM,1)=B(CM-1,1)+ convert*(Data(CM,3) - spreadA);  
   else
    A(CM,1)=A(CM-1,1);
    B(CM,1)=B(CM-1,1);
 end
  month(CM,1)=CM;  %% Keep Track of Transaction Months
  TOTALA(CM,1)= A(CM,1)*(Data(CM0,1)/Data(CM,1)) + (B(CM,1)* (Data(CM0,2)/Data(CM,2))/Data(CM0,3))-A0-B0/Data(CM0,3);
  TOTALB(CM,1)= (A(CM,1)*(Data(CM0,1)/Data(CM,1)))*Data(CM0,3) + B(CM,1)* (Data(CM0,2)/Data(CM,2))-B0-A0*Data(CM0,3);
  NOEXA(CM,1)=Data(CM0,1)/Data(CM,1) + (Data(CM0,2)/Data(CM,2))/Data(CM0,3)-(1+1/Data(CM0,3));
  NOEXB(CM,1)=(Data(CM0,1)/Data(CM,1))*Data(CM0,3) + Data(CM0,2)/Data(CM,2)-(1+Data(CM0,3));
end