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
% clear c3 label sstring 
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
difficulty=1-dif;
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
tt=table(trials,resp,prevresp,lc,rc,reward,Strategy,Categories,went_left,deltaC,stim_stay,difficulty,prev_deltaC,prev_win,stay,mouse,respt);
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

m5 = fitglm(tt(good,:), 'stay ~ stim_stay + prev_win * difficulty','Distribution','binomial');
%%
s1=fitglm(tt(good,:),'stay ~ stim_stay','Distribution','binomial');
s2=fitglm(tt(good,:),'stay ~ stim_stay + prev_win ','Distribution','binomial');
s3=fitglm(tt(good,:),'stay ~ stim_stay + prev_win+ difficulty','Distribution','binomial');

s4=fitglm(tt(good,:),'stay ~ stim_stay * prev_win ','Distribution','binomial');
s5=fitglm(tt(good,:),'stay ~ stim_stay * prev_win+ difficulty','Distribution','binomial');


s6=fitglm(tt(good,:),'stay ~ stim_stay + prev_win * difficulty','Distribution','binomial');
s7=fitglm(tt(good,:),'stay ~ stim_stay * prev_win * difficulty','Distribution','binomial');
s8=fitglm(tt(good,:),'stay ~ prev_win + stim_stay * difficulty','Distribution','binomial');
s9=fitglm(tt(good,:),'stay ~ prev_win * stim_stay + difficulty','Distribution','binomial');
% s6=fitglme(tt(good,:),'stay ~ stim_stay * prev_win * difficulty+ (difficulty | mouse) ','Distribution','binomial');
%%
varNames = {'Criterion','s1','s2','s3','s4','s5','s6'};

mcs1=dataset2cell(s1.ModelCriterion);
mcs2=dataset2cell(s2.ModelCriterion);
mcs3=dataset2cell(s3.ModelCriterion);
mcs4=dataset2cell(s4.ModelCriterion);
mcs5=dataset2cell(s5.ModelCriterion);
mcs6=dataset2cell(s6.ModelCriterion);

MCStable=table(categorical({'AIC';'BIC';'LogLiklihood';'Deviance'}),...
    cell2mat(mcs1(2,:))',...
    cell2mat(mcs2(2,:))',...
    cell2mat(mcs3(2,:))',...
    cell2mat(mcs4(2,:))',...
    cell2mat(mcs5(2,:))',...
    cell2mat(mcs6(2,:))',...
    'VariableNames',varNames);
%
varNames = {'m1','m2','m3','m4','m4e','h1','h2','m5'};
%%
% tt.m5 = predict(m5);

% gs = grpstats(tt,{'stim_stay','prev_win','difficulty'},'mean','DataVars',{'stay','m5'});
%%
varNames = {'Criterion','m1','m2','m3','m4','h1','h2','m5'};
MCtable=table(categorical({'AIC';'AICc';'BIC';'CAIC'}),...
    cell2mat(struct2cell(m1.ModelCriterion)),...
    cell2mat(struct2cell(m2.ModelCriterion)),...
    cell2mat(struct2cell(m3.ModelCriterion)),...
    cell2mat(struct2cell(m4.ModelCriterion)),...
    cell2mat(struct2cell(h1.ModelCriterion)),...
    cell2mat(struct2cell(h2.ModelCriterion)),...
    cell2mat(struct2cell(m5.ModelCriterion)),...
    'VariableNames',varNames);
%
varNames = {'m1','m2','m3','m4','m4e','h1','h2','m5'};
% it seems m5 is has the best criteria
%%
% we should plot the model (m5) prediction vs real data but we couldn't :))))

%%
c1t=find(sumC(good)==0);
%C2: One Side Stimulus
c2t=find(rc(good).*lc(good)==0&sumC(good)~=0);
% c2t=c2t(3:end);
%C3: Different Contrast
c3t=find(sumC(good)~=0&rc(good).*lc(good)~=0&dif(good)~=0);
%C4: Same Conttast
c4t=find(dif(good)==0&sumC(good)~=0);
Categories=cell(length(good),1);

Categories(c2t)={'One-Side'};
Categories(c3t)={'Different-Contrast'};
Categories(c4t)={'Same-Contrast'};

 %%
y=[histcounts(strategy(c2t,2));histcounts(strategy(c3t,2));histcounts(strategy(c4t,2))];

c=unique(Categories);
ccc=c{1};c{1}=c{2};c{2}=c{3};c{3}=ccc;
clear c3 label sstring 
c=categorical(c); 

figure;bar(c,y)
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Trial counts';legend('Location','northeastoutside');
% saveas(gcf,'bar','emf')
figure;bar(c,y./sum(y,2))
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Normalized Trial Counts';legend('Location','northeastoutside');
% saveas(gcf,'barnorm','emf')
%%
super=find(resp~=0&sumC~=0&reward~=-1);
c1t=find(sumC(super)==0);
%C2: One Side Stimulus
c2t=find(rc(super).*lc(super)==0&sumC(super)~=0);
% c2t=c2t(3:end);
%C3: Different Contrast
c3t=find(sumC(super)~=0&rc(super).*lc(super)~=0&dif(super)~=0);
%C4: Same Conttast
c4t=find(dif(super)==0&sumC(super)~=0);
Categories=cell(length(super),1);

Categories(c2t)={'One-Side'};
Categories(c3t)={'Different-Contrast'};
Categories(c4t)={'Same-Contrast'};


y=[histcounts(strategy(c2t,2));histcounts(strategy(c3t,2));histcounts(strategy(c4t,2))];

c=unique(Categories);
ccc=c{1};c{1}=c{2};c{2}=c{3};c{3}=ccc;
clear c3 label sstring 
c=categorical(c); 

figure;bar(c,y)
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Trial counts';legend('Location','northeastoutside');
% saveas(gcf,'bar','emf')
figure;bar(c,y./sum(y,2))
legend({'Win-Stay';'Win-Switch';'Lose-Stay';'Lose-Switch'});
ylabel 'Normalized Trial Counts';legend('Location','northeastoutside');
% saveas(gcf,'barnorm','emf')
%%
mname='s1';
ttgood.h2 = predict(s1);
gs=grpstats(ttgood,{'stim_stay','difficulty'},{'mean','meanci'},'DataVars',{'stay','h2'});
sttm0=find(gs.stim_stay==0);
sttm1=find(gs.stim_stay==1);
figure;
subplot(2,1,1); plot(gs.difficulty(sttm0),gs.mean_stay(sttm0),'b')
hold on;plot(gs.difficulty(sttm0),gs.mean_h2(sttm0),'r');
hold on;plot(gs.difficulty(sttm0),gs.meanci_stay(sttm0,1),'b--')
hold on;plot(gs.difficulty(sttm0),gs.meanci_h2(sttm0,1),'r--')
hold on;plot(gs.difficulty(sttm0),gs.meanci_stay(sttm0,2),'b--')
hold on;plot(gs.difficulty(sttm0),gs.meanci_h2(sttm0,2),'r--')
ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=0'
xticks([0,0.25,0.5,0.75,1])
subplot(2,1,2);plot(gs.difficulty(sttm1),gs.mean_stay(sttm1))
hold on;plot(gs.difficulty(sttm1),gs.mean_h2(sttm1))
hold on;plot(gs.difficulty(sttm1),gs.meanci_stay(sttm1,1),'b--')
hold on;plot(gs.difficulty(sttm1),gs.meanci_h2(sttm1,1),'r--')
hold on;plot(gs.difficulty(sttm1),gs.meanci_stay(sttm1,2),'b--')
hold on;plot(gs.difficulty(sttm1),gs.meanci_h2(sttm1,2),'r--')
xlabel 'Left Contrast - Right Contrast';ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=1'
xticks([0,0.25,0.5,0.75,1])
saveas(gcf,['dc',mname],'jpg')
%%
mname='s6';
ttgood.h2 = predict(s6);
gs=grpstats(ttgood,{'stim_stay','deltaC'},{'mean','meanci'},'DataVars',{'stay','h2'});
sttm0=find(gs.stim_stay==0);
sttm1=find(gs.stim_stay==1);
figure;
subplot(2,1,1); plot(gs.deltaC(sttm0),gs.mean_stay(sttm0),'b')
hold on;plot(gs.deltaC(sttm0),gs.mean_h2(sttm0),'r');
hold on;plot(gs.deltaC(sttm0),gs.meanci_stay(sttm0,1),'b--')
hold on;plot(gs.deltaC(sttm0),gs.meanci_h2(sttm0,1),'r--')
hold on;plot(gs.deltaC(sttm0),gs.meanci_stay(sttm0,2),'b--')
hold on;plot(gs.deltaC(sttm0),gs.meanci_h2(sttm0,2),'r--')
ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=0'
xticks([-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1])
subplot(2,1,2);plot(gs.deltaC(sttm1),gs.mean_stay(sttm1))
hold on;plot(gs.deltaC(sttm1),gs.mean_h2(sttm1))
hold on;plot(gs.deltaC(sttm1),gs.meanci_stay(sttm1,1),'b--')
hold on;plot(gs.deltaC(sttm1),gs.meanci_h2(sttm1,1),'r--')
hold on;plot(gs.deltaC(sttm1),gs.meanci_stay(sttm1,2),'b--')
hold on;plot(gs.deltaC(sttm1),gs.meanci_h2(sttm1,2),'r--')
xlabel 'Left Contrast - Right Contrast';ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=1'
xticks([-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1])
saveas(gcf,['dc',mname],'jpg')

%%
tt.sumC=sumC;
ttgood=tt(good,:);
%%
mname='s1';
ttgood.h2 = predict(s1);
gs=grpstats(ttgood,{'stim_stay','sumC'},{'mean','meanci'},'DataVars',{'stay','h2'});
sttm0=find(gs.stim_stay==0);
sttm1=find(gs.stim_stay==1);
figure;
subplot(2,1,1); plot(gs.sumC(sttm0),gs.mean_stay(sttm0),'b')
hold on;plot(gs.sumC(sttm0),gs.mean_h2(sttm0),'r');
hold on;plot(gs.sumC(sttm0),gs.meanci_stay(sttm0,1),'b--')
hold on;plot(gs.sumC(sttm0),gs.meanci_h2(sttm0,1),'r--')
hold on;plot(gs.sumC(sttm0),gs.meanci_stay(sttm0,2),'b--')
hold on;plot(gs.sumC(sttm0),gs.meanci_h2(sttm0,2),'r--')
ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=0'
xticks(unique(sumC));axis tight
subplot(2,1,2);plot(gs.sumC(sttm1),gs.mean_stay(sttm1))
hold on;plot(gs.sumC(sttm1),gs.mean_h2(sttm1))
hold on;plot(gs.sumC(sttm1),gs.meanci_stay(sttm1,1),'b--')
hold on;plot(gs.sumC(sttm1),gs.meanci_h2(sttm1,1),'r--')
hold on;plot(gs.sumC(sttm1),gs.meanci_stay(sttm1,2),'b--')
hold on;plot(gs.sumC(sttm1),gs.meanci_h2(sttm1,2),'r--')
xlabel 'Left Contrast + Right Contrast';ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=1'
xticks(unique(sumC));axis tight
saveas(gcf,['Sc',mname],'jpg')
%%
mouse=[];
for i=1:10
    mouse=[mouse;repmat(i,te(i+1)-te(i),1)];
end
tt.mouse=mouse;
ttgood=tt(good,:);
%%
% gs=grpstats(ttgood,{'stay','difficulty','prev_win','h2'},{'numel'},'DataVars',{'stay','h2'});
mname='s9';
ttgood.h2 = (sign(predict(s9)-0.6)+1)/2;

pw0=find(ttgood.prev_win==0);
pw1=find(ttgood.prev_win==1);
stvsdfpw0=[];mdlvsdfpw0=[];
stvsdfpw1=[];mdlvsdfpw1=[];
ud=unique(difficulty);
for i=1:length(ud)
   stvsdfpw0=[stvsdfpw0,100*length(find(ttgood.stay(pw0)==1&ttgood.difficulty(pw0)==ud(i)))/length(find(ttgood.difficulty(pw0)==ud(i)))];
   stvsdfpw1=[stvsdfpw1,100*length(find(ttgood.stay(pw1)==1&ttgood.difficulty(pw1)==ud(i)))/length(find(ttgood.difficulty(pw1)==ud(i)))];

   mdlvsdfpw0=[mdlvsdfpw0,100*length(find(ttgood.h2(pw0)==1&ttgood.difficulty(pw0)==ud(i)))/length(find(ttgood.difficulty(pw0)==ud(i)))];
   mdlvsdfpw1=[mdlvsdfpw1,100*length(find(ttgood.h2(pw1)==1&ttgood.difficulty(pw1)==ud(i)))/length(find(ttgood.difficulty(pw1)==ud(i)))];

end
figure;plot(ud,mdlvsdfpw1,'b-');hold on;plot(ud,mdlvsdfpw0,'r-');
hold on;plot(ud,stvsdfpw0,'ro');
hold on;plot(ud,stvsdfpw1,'bo');hold on;plot(ud,stvsdfpw0,'ro');
xticks(ud);xlabel 'Difficulty (1-abs(\DeltaC))';ylabel 'P Stay(%)';legend({'Pre-win=0';'Pre-win=1'})
legend('Location','northeastoutside');title ([mname 'Model'])
saveas(gcf,['pstvsdf',mname],'jpg')
%%
sttm0=find(gs.stay==0);
sttm1=find(gs.stay==1);

figure;
subplot(2,1,1); plot(gs.mouse(sttm0),gs.mean_stay(sttm0),'b')
hold on;plot(gs.mouse(sttm0),gs.mean_h2(sttm0),'r');
hold on;plot(gs.mouse(sttm0),gs.meanci_stay(sttm0,1),'b--')
hold on;plot(gs.mouse(sttm0),gs.meanci_h2(sttm0,1),'r--')
hold on;plot(gs.mouse(sttm0),gs.meanci_stay(sttm0,2),'b--')
hold on;plot(gs.mouse(sttm0),gs.meanci_h2(sttm0,2),'r--')
ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=0'
xticks(unique(mouse)); axis tight
subplot(2,1,2);plot(gs.mouse(sttm1),gs.mean_stay(sttm1))
hold on;plot(gs.mouse(sttm1),gs.mean_h2(sttm1))
hold on;plot(gs.mouse(sttm1),gs.meanci_stay(sttm1,1),'b--')
hold on;plot(gs.mouse(sttm1),gs.meanci_h2(sttm1,1),'r--')
hold on;plot(gs.mouse(sttm1),gs.meanci_stay(sttm1,2),'b--')
hold on;plot(gs.mouse(sttm1),gs.meanci_h2(sttm1,2),'r--')
xlabel 'Mouse Number';ylabel 'Mean';legend ({'Data';[mname,'-Model']});title 'Stay=1'
xticks(unique(mouse));axis tight
saveas(gcf,['Mc',mname],'jpg')
%%
%y=stay;   x=difficulty Plot1: prev_win=0 Plot2: prev_win=1 
stim stay difficulty
% x=diff y= por stay P1=