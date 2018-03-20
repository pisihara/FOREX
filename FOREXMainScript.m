%%% Main script to do ppp forex simulations
clear all; close all; format long;
%Read CPI and Exchange rate Data Country A=US; Country B = Great Britain
Data=xlsread('USGBData.xlsx','Sheet1','B2:D56'); 

%% Set parameters
A0=1; B0=1;  %% initial units of currencies A and B
CM0=25; %% Initial  month 
n=24;  %% Number of data used in regression
spreadA =0;  % brokerage cost exchanging A to B
spreadB =0; % brokerage cost exchanging B to A
fractionA =.5; % fraction of A exchanged
fractionB =.5; %  fraction of B exchanged
R2Amin = .85;  % threshold R^2 for CPI A regression
R2Bmin = .85;  % threshold R^2 for CPI B regression
month(CM0,1)=CM0;  %% record initial month before trading

%% Perform Exchanges through the last month of data
[TOTALA,TOTALB,NOEXA,NOEXB,A,B,R2A,R2B,month]=FOREX(A0,B0,Data,CM0,n,spreadA,spreadB, fractionA, fractionB, R2Amin,R2Bmin);

%PRODUCE OUTPUT PLOT FOR THE ENTIRE TRADING PERIOD
n1=CM0;  n2=length(Data);
figure; %%In Currency A
plot(month(n1:n2,1), A(n1:n2,1),'-+b'); hold on 
plot(month(n1:n2,1),B(n1:n2,1),'-+r'); hold on 
plot(month(n1:n2,1), TOTALA(n1:n2,1),'k'); hold on
plot(month(n1:n2,1), NOEXA(n1:n2,1),'g'); hold on
plot(month(n1:n2-1,1),R2A(n1:n2-1,1),'-ob'); hold on
plot(month(n1:n2-1,1),R2B(n1:n2-1,1),'-or'); hold on
text(28,2.85, strcat('PARAMETERS:  ','SpreadA= ',num2str(spreadA), ', SpreadB= ',num2str(spreadB),   ', FracAexch=',num2str(fractionA),  ', FracBexch=',num2str(fractionB),  ', minR^2 A =', num2str(R2Amin)  ,', minR^2 B = ', num2str(R2Bmin), ', number data used in regression of CPI=', num2str(n))); 
xlabel('Month'); 
legend('USD', 'GBP','Gain/Loss in USD','NOEX Gain/Loss', strcat('R^2 for USD CPI  n=', num2str(n)), strcat('R^2 for GB CPI  n=  ',num2str(n)), 'location','southoutside');
title(strcat('ADJUSTED TOTAL GAIN/LOSS (in USD): Initial=', num2str(TOTALA(CM0,1)), ', Max=', num2str(max(TOTALA(:,1))),  ', Min=',  num2str(min(TOTALA(CM0:length(Data) ,1))),  ', Final= ', num2str(TOTALA(length(Data),1)))); 

figure; %% In Currency B
plot(month(n1:n2,1), A(n1:n2,1),'-+b'); hold on 
plot(month(n1:n2,1),B(n1:n2,1),'-+r'); hold on 
plot(month(n1:n2,1), TOTALB(n1:n2,1),'k'); hold on
plot(month(n1:n2,1), NOEXB(n1:n2,1),'g'); hold on
plot(month(n1:n2-1,1),R2A(n1:n2-1,1),'-ob'); hold on
plot(month(n1:n2-1,1),R2B(n1:n2-1,1),'-or'); hold on
text(28,2.85, strcat('PARAMETERS:  ','SpreadA= ',num2str(spreadA), ', SpreadB= ',num2str(spreadB),   ', FracAexch=',num2str(fractionA),  ', FracBexch=',num2str(fractionB),  ', minR^2 A =', num2str(R2Amin)  ,', minR^2 B = ', num2str(R2Bmin), ', number data used in regression of CPI=', num2str(n))); 
xlabel('Month'); 
legend('USD', 'GBP','Gain/Loss in GBP','NOEX Gain/Loss', strcat('R^2 for USD CPI  n=', num2str(n)), strcat('R^2 for GB CPI  n=  ',num2str(n)), 'location','southoutside');
title(strcat('ADJUSTED TOTAL GAIN/LOSS(in GBP): Initial=', num2str(TOTALB(CM0,1)), ', Max=', num2str(max(TOTALB(:,1))),  ', Min=',  num2str(min(TOTALB(CM0:length(Data) ,1))),  ', Final= ', num2str(TOTALB(length(Data),1)))); 


