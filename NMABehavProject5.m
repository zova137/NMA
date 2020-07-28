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
saveas(gcf,'bar','jpg')
figure;bar(c,y./sum(y,2))
legend({'Win-Stay';'Win-Switch';'Loose-Stay';'Loos-Switch'});
ylabel 'Normalized Trial Counts';legend('Location','northeastoutside');
saveas(gcf,'barnorm','emf')
saveas(gcf,'barnorm','jpg')
%%
mousetrial=[3,4,4,7,3,3,5,5,4,1];
mstl=cumsum(mousetrial);
trialst=find(bdata(:,1)==0);trialst=[trialst(2:end);length(bdata(:,1))];trialend=[0];
for i=1:10
    trialend=[trialend,trialst(mstl(i))];
end
te=trialend;
%%
figure(1);figure(2)
c=unique(Categories);
c3=c{3};c{3}=c{1};c{1}=c{2};c{2}=c3;
clear c3 label sstring 
c=categorical(c); 
for i=1:9
    y=[];gc=c;
y=[histcounts(strategy(c1t(find(c1t>te(i)&c1t<te(i+1))),2));...
     histcounts(strategy(c2t(find(c2t>te(i)&c2t<te(i+1))),2));...
     histcounts(strategy(c3t(find(c3t>te(i)&c3t<te(i+1))),2));...
     histcounts(strategy(c4t(find(c4t>te(i)&c4t<te(i+1))),2))];

figure(1)
subplot(3,3,i);

bar(gc,y)
title (sprintf('Mouse #%d',i))
if i==7
   xticks=[];
    ylabel 'Trial counts';
end
if i==3
    legend({'Win-Stay';'Win-Switch';'Loose-Stay';'Loos-Switch'});
% legend('Location','northoutside');
end

figure(2)
subplot(3,3,i);

bar(gc,y./sum(y,2))
title (sprintf('Mouse #%d',i))
if i==7
    xticks=[];
    ylabel 'Normalized Trial Counts';
end
if i==3
    legend({'Win-Stay';'Win-Switch';'Loose-Stay';'Loos-Switch'});
% legend('Location','northoutside');
end
end


saveas(figure(1),'barmouse','emf')
saveas(figure(1),'barmouse','jpg')
saveas(figure(2),'barnormmouse','emf')
saveas(figure(2),'barnormmouse','jpg')