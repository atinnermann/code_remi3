function target_temp = analyse_calib(subject)

if nargin==0, subject = input('Subject ID: '); end
figure
% load calib data
p = [];

% list = ls(sprintf('*sub%02.0f_train*',subject));
cdir = pwd;
load(fullfile(cdir,'logs',sprintf('sub%02.0f',subject),sprintf('sub%02.0f_train.mat',subject)));

% set params
trialsel = [1:22];
target_vas = [50; 60; 70];

triallist = p.realTrialList;
y = NaN(size(triallist));

y(1:4) = p.Rating;
y([5 10 17 20]) = [mean([p.Rating1(5) p.Rating2(5)]) mean([p.Rating1(8) p.Rating2(8)]) mean([p.Rating1(13) p.Rating2(13)]) mean([p.Rating1(15) p.Rating2(15)])];
y([6 8 18 21]) = p.Rating1([6 7 14 16]);
y([7 9 19 22]) = p.Rating2([6 7 14 16]);
y(11) = max(p.log.onratings.conRating{1});
y([13 16]) = [mean(p.log.onratings.conRating{2}) mean(p.log.onratings.conRating{4})];
y = y(:);
y = y(trialsel);
X = p.realtemps(:); X = X(trialsel);
trial = [1:numel(X)]';
X(isnan(y))=[];
trial(isnan(y))=[];
y(isnan(y))=[];


% estimate linear function
blin = [ones(numel(X),1) X]\y;
est_lin(1) = linreverse(blin,target_vas(1));
est_lin(2) = linreverse(blin,target_vas(2));
est_lin(3) = linreverse(blin,target_vas(3));

% estimate sigmoid function
a = mean(X); b = 1; % L = 0; U = 100; % l/u bounds to be fitted
beta0 = [a b];
options = statset('Display','final','Robust','on','MaxIter',10000);
[bsig,~] = nlinfit(X,y,@localsigfun,beta0,options);

est_sig(1) = sigreverse([bsig 0 100],target_vas(1));
est_sig(2) = sigreverse([bsig 0 100],target_vas(2));
est_sig(3) = sigreverse([bsig 0 100],target_vas(3));

% plot
xplot = 40:.1:48;
plot(X,y,'kx');
plot(X,y,'kx',xplot,localsigfun(bsig,xplot),'r',...
     est_sig,localsigfun(bsig,est_sig),'ro',est_lin,target_vas,'kd',...
     xplot,blin(1)+xplot.*blin(2),'k--');
xlim([min(xplot)-.5 max(xplot)+.5]); ylim([0 100]);

% display
target_temp = est_sig; %clc;
results = [trial X y];
disp(results);
fprintf(1,'estimates from sigmoidal fit (n=%d)\n\n',numel(trialsel));
fprintf(1,'50 : %2.1f °C \tlinear: %2.1f °C\n',target_temp(1),est_lin(1));
fprintf(1,'60 : %2.1f °C \tlinear: %2.1f °C\n',target_temp(2),est_lin(2));
fprintf(1,'70 : %2.1f °C \tlinear: %2.1f °C\n',target_temp(3),est_lin(3));

    function xsigpred = sigreverse(bsig1,ytarget)
        v=.5; a1 = bsig1(1); b1 = bsig1(2); L1 = bsig1(3); U1 = bsig1(4);
        xsigpred = a1 + 1/-b1 * log((((U1-L1)/(ytarget-L1))^v-1)./v);
    end

    function xlinpred = linreverse(blin1,ytarget)
        a1 = blin1(1); b1 = blin1(2);
        xlinpred = (ytarget - a1) / b1;
    end
end