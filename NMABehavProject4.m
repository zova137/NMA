bdata = xlsread('output.xlsx',3);
trials=bdata(:,2);
prevresp=bdata(:,3);
lc=bdata(:,5);
rc=bdata(:,8);
resp=bdata(:,end);
respt=bdata(:,4);
reward=bdata(:,9);

dir=lc-rc;dif=abs(dir);sum=lc+rc;
%% 
wst=find(reward==1&[diff(resp);1]==0);
wsw=find(reward==1&[diff(resp);0]~=0);
lst=find(reward==-1&[diff(resp);1]==0);
lsw=find(reward==-1&[diff(resp);0]~=0);
strategy=[wst;wsw;lst;lsw];
label=[ones(length(wst),1);2*ones(length(wsw),1);...
             3*ones(length(lst),1);4*ones(length(lsw),1)];
strategy=sortrows([strategy,label]);
sttring=cell(length(label),1);
sttring(find(strategy(:,2)==1))={'Win_Stay'};
sttring(find(strategy(:,2)==2))={'Win_Switch'};
sttring(find(strategy(:,2)==3))={'Loose_Stay'};
sttring(find(strategy(:,2)==4))={'Loose_Switch'};
strategy=[1,1;strategy];
Strategy=[{'-'};sttring];
%%
c1t=find(sum==0);
%C2: One Side Stimulus
c2t=find(rc.*lc==0&sum~=0);
% c2t=c2t(3:end);
%C3: Different Contrast
c3t=find(sum~=0&rc.*lc~=0&dif~=0);
%C4: Same Conttast
c4t=find(dif==0&sum~=0);
Categories=cell(length(label),1);
Categories(c1t)={'No-Go'};
Categories(c2t)={'One-Side'};
Categories(c3t)={'Different-Contrast'};
Categories(c4t)={'Same-Contrast'};
%%
 tt=table(trials,resp,prevresp,lc,rc,reward,Strategy,Categories);
 %%
y=[histcounts(strategy(c1t,2));histcounts(strategy(c2t,2));histcounts(strategy(c3t,2));histcounts(strategy(c4t,2))];

c=unique(Categories);
c3=c{3};c{3}=c{1};c{1}=c{2};c{2}=c3;
clear c3 label sstring 
c=categorical(c); 

figure;bar(c,y)
legend({'Win-Stay';'Win-Switch';'Loose-Stay';'Loos-Switch'});
ylabel 'Trial counts';legend('Location','northeastoutside');
saveas(gcf,'bar','emf')
figure;bar(c,y./sum(y,2))
legend({'Win-Stay';'Win-Switch';'Loose-Stay';'Loos-Switch'});
ylabel 'Normalized Trial Counts';legend('Location','northeastoutside');
saveas(gcf,'barnorm','emf')