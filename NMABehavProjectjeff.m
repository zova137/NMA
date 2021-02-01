bdata = xlsread('output.xlsx',3);
trials=bdata(:,2);
prevresp=bdata(:,3);
lc=bdata(:,5);
rc=bdata(:,8);
resp=bdata(:,end);
respt=bdata(:,4);
reward=bdata(:,9);

deltaC=lc-rc;dif=abs(deltaC);sumC=lc+rc;
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
sttring(find(strategy(:,2)==3))={'Lose_Stay'};
sttring(find(strategy(:,2)==4))={'Lose_Switch'};
strategy=[1,1;strategy];
Strategy=[{'Win_Stay'};sttring];
%%
c1t=find(sumC==0);
%C2: One Side Stimulus
c2t=find(rc.*lc==0&sumC~=0);
% c2t=c2t(3:end);
%C3: Different Contrast
c3t=find(sumC~=0&rc.*lc~=0&dif~=0);
%C4: Same Conttast
c4t=find(dif==0&sumC~=0);
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
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Trial counts';legend('Location','northeastoutside');
saveas(gcf,'bar','emf')
figure;bar(c,y./sum(y,2))
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Normalized Trial Counts';legend('Location','northeastoutside');
saveas(gcf,'barnorm','emf')

tt.reward = tt.reward==1;
good=find(resp~=0&sumC~=0);
% wlt=find(resp==1);
% wlf=find(resp==-1);
% went_left=cell(length(resp),1);
% went_left(wlt)={'true'};
% went_left(wlf)={'false'};
went_left=(resp+1)/2;
difficulty=dif;
reward=(reward+1)/2;
prev_deltaC=[deltaC(1);deltaC(1:end-1)];
prev_win=[reward(1);reward(1:end-1)];
stay=[0;~diff(resp)];
stim_stay=[0;~diff(sign(deltaC))];
%
mousetrial=[3,4,4,7,3,3,5,5,4,1];
mna=['a','b','c','d','e','f','g','h','j','k'];
mstl=[cumsum(mousetrial)];
trialst=find(bdata(:,1)==0);trialst=[trialst(2:end);length(bdata(:,1))];trialend=[0];mouse=[];
for i=1:10
    trialend=[trialend,trialst(mstl(i))];
end
te=trialend;
for i=1:10
    mouse=[mouse;repmat(mna(i),te(i+1)-te(i),1)];
end
%
tt=table(trials,resp,prevresp,lc,rc,reward,Strategy,Categories,went_left,deltaC,stim_stay,difficulty,prev_deltaC,prev_win,stay,mouse);
%% 
gs = grpstats(tt(good,:), {'Strategy','deltaC'},'meanci','DataVars','went_left')
gs.Strategy = categorical(gs.Strategy);
strats = unique(gs.Strategy);
stit={'Lose-Stay';'Lose-Switch';'Win-Stay';'Win-Switch'};
for sx=1:4
    ax = subplot(2,2,sx);
    thisidx = gs.Strategy == strats(sx);
    mci = gs.meanci_went_left(thisidx,:);
    draw.errorplot(ax, gs.deltaC(thisidx), mci(:,2), mci(:,1));
     title(stit(sx));
    set(ax,'YLim',[0 1])
    draw.xhairs(ax,'k-',0,0.5);
end
modelspec = 'went_left ~ deltaC';
m1 = fitglm(tt(good,:),modelspec,'Distribution','binomial');
m2 = fitglm(tt(good,:),'went_left ~ deltaC + Strategy','Distribution','binomial');
m3 = fitglm(tt(good,:),'went_left ~ deltaC + Strategy + difficulty','Distribution','binomial');
m4 = fitglm(tt(good,:),'went_left ~ deltaC + difficulty * Strategy','Distribution','binomial');

m4e = fitglme(tt(good,:),'went_left ~ deltaC + difficulty * Strategy + (deltaC | mouse)','Distribution','binomial');

h1 = fitglm(tt(good,:),'reward ~ difficulty','Distribution','binomial');
h2 = fitglm(tt(good,:),'reward ~ difficulty + Strategy','Distribution','binomial');

ttgood = tt(good,:);
ttgood.h2 = predict(h2);

tt.stim_stay = (tt.prev_deltaC .* tt.deltaC)>0;

m5 = fitglm(tt, 'stay ~ stim_stay + prev_win * difficulty','Distribution','binomial');
tt.m5 = predict(m5);

gs = grpstats(tt,{'stim_stay','prev_win','difficulty'},'mean','DataVars',{'stay','m5'});
%%
varNames = {'Criterion','m1','m2','m3','m4','h1','h2','m5'};
MCtable=table(categorical({'AIC';'AICc';'BIC';'CAIC'}),...
    cell2mat(struct2cell(m1.ModelCriterion)),...
    cell2mat(struct2cell(m2.ModelCriterion)),...
    cell2mat(struct2cell(m3.ModelCriterion)),...
    cell2mat(struct2cell(m4.ModelCriterion)),...
    cell2mat(struct2cell(h1.ModelCriterion)),...
    cell2mat(struct2cell(h2.ModelCriterion)),...
    cell2mat(struct2cell(m5.ModelCriterion)),'VariableNames',varNames);
%
varNames = {'m1','m2','m3','m4','m4e','h1','h2','m5'};
% it seems m5 is has the best criteria
%%
% we should plot the model (m5) prediction vs real data but we couldn't :))))



