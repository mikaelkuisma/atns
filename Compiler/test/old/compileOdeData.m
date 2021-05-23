function Data = compileOdeData(Data,Options)

if ~exist('normrnd','builtin')
    normrnd = @(mu,sigma,M,N)sigma*randn(M,N)+mu;
end

GINFO = Data.GuildInfo;

% calculate relative prey preference matrix
ng = size(Data.adjacencyMatrix,1);
nps = 1./sum(Data.adjacencyMatrix,2);
nps(isinf(nps)) = 0;
Data.omega = Data.adjacencyMatrix.*repmat(nps,1,ng);

% New variables resized to avoid unnecessary computation and memory usage

adjacencyMatrix = Data.adjacencyMatrix(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'adjacencyMatrix');

% Data.adjacencyMatrix = adjacencyMatrix;
[I, J] = find(adjacencyMatrix);
Data.I = I(:);
Data.J = J(:);
IJ = find(adjacencyMatrix);
Data.IJ = IJ(:);

c = vertcat(Data.Guilds(GINFO.iProducerGuilds).c);
Data.c = c;
C = repmat(c,1,GINFO.nProducerGuilds)-diag(c);

% TODO: move this elsewhere
if nargin < 2 || ~isfield(Options,'intraspecificProducerCompetitionCoefficient')
    Options.intraspecificProducerCompetitionCoefficient = 2.0225;
end

c_intra = Options.intraspecificProducerCompetitionCoefficient*ones(size(c));
C = C+diag(c_intra);
C = sum(sum(pinv(C)))*C;
Data.C = C;

Data.r = vertcat(Data.Guilds(GINFO.iProducerGuilds).igr);

% Data.f_m = vertcat(Data.Guilds(GINFO.iFeederGuilds).f_m);
% f_m = vertcat(Data.Guilds(GINFO.iFeederGuilds).f_m);
f_m = vertcat(Data.Guilds(GINFO.iConsumerAndFishGuilds).f_m);
% Data.f_m = f_m;

Data.s = vertcat(Data.Guilds(GINFO.iProducerGuilds).s);
Data.diss_rate = [];
if ~isempty(GINFO.iPOC)
    Data.diss_rate = Data.Guilds(GINFO.iPOC).diss_rate;
end
Data.hatchery = vertcat(Data.Guilds(GINFO.iFishGuilds).hatchery);

f_a = vertcat(Data.Guilds(GINFO.iFeederGuilds).f_a);
% Data.f_a = f_a;
Data.f_aDiagMTX = [];
if ~isempty(f_a)
    Data.f_aDiagMTX = spdiags(f_a,0,length(f_a),length(f_a));
    % Data.f_aFullDiagMTX = diag(Data.f_a);
end
Data.f_aVec = f_a(I);

Data.invest = vertcat(Data.Guilds(GINFO.iFishGuilds).invest);
if ~isfield(Data.Guilds,'Pmat')
    for i = GINFO.iFishGuilds
        Data.Guilds(i).Pmat = proba_mature(0,Data.Guilds(i).age);
    end
end
Data.P_mat = vertcat(Data.Guilds(GINFO.iFishGuilds).Pmat);

for i = GINFO.iFishGuilds
    g = Data.Guilds(i);
    if ~isfield(g, 'mbr') || isempty(g.mbr)
        Iref = find([Data.Guilds.isRefGuild]);
        aRef = 1; % assuming the reference guild is a producer for all of which a=1
        Mref = 6.4e-5; % If no reference guild body mass. Use this default from LC
        if ~isempty(Iref)
            grefBM = Data.Guilds(Iref).bodymass;
            if ~isnan(grefBM) && isnumeric(grefBM) && grefBM > 0
                Mref = grefBM;
            end
        end
        Data.Guilds(i).mbr = metabolicRate(gavgl,glw_a,glw_b,gtype,Mref,aRef);
%         Data.Guilds(i).mbr = metabolicRate(g.avgl,g.lw_a,g.lw_b);
    end
end
%Data.x = vertcat(Data.Guilds(GINFO.iConsumerAndFishGuilds).mbr);
x = vertcat(Data.Guilds(GINFO.iConsumerAndFishGuilds).mbr);
% x = vertcat(Data.Guilds(GINFO.iFeederGuilds).mbr);
% x_consumers = x(Data.GuildInfo.iConsumerGuildsInFeeders);
Data.x = x;
% Data.x_consumers = x_consumers;
Data.xVec = x(Data.I); 

omega = Data.omega(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'omega');
% Data.omega = omega;
omegaVec = full(omega(IJ));
Data.omegaVec = omegaVec(:);

B0 = Data.B0(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'B0');
% Data.B0 = B0;
B0Vec = full(B0(IJ));
Data.B0Vec = B0Vec(:);

d = Data.d(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'d');
% Data.d = d;
dVec = full(d(IJ));
Data.dVec = dVec(:);

q = Data.q(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'q');
% Data.q = q;
qVec = full(q(IJ));
Data.qVec = qVec(:);

e = Data.e(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'e');
Data.e = e;
eVec = full(e(IJ));
Data.eVec = eVec(:);

y = Data.y(GINFO.iFeederGuilds,GINFO.iFoodGuilds);
Data = rmfield(Data,'y');
Data.y = y;
yVec = full(y(IJ));
Data.yVec = yVec(:);

Data.B0_pow_q = zeros(GINFO.nFeederGuilds,GINFO.nFoodGuilds);
Data.B0_pow_q(IJ) = Data.B0Vec.^Data.qVec;
% Data.B0_pow_q = Data.B0.^Data.q;
% Data.B0_pow_q = Data.B0_pow_q.*Data.adjacencyMatrix;
% Data.B0_pow_qVec = Data.B0_pow_q(IJ);
Data.B0_pow_qVec = Data.B0Vec.^Data.qVec;
Data = rmfield(Data,'B0_pow_q');

Data.f_mx = f_m.*x;
% if length(GINFO.iConsumerAndFishGuilds) ~= length(Data.f_mx)
%     keyboard
% end

switch Data.K.type
    case 'Constant'
        K = repmat(Data.K.mean,1,Data.nYearsFwd);
    case 'White noise'
        K = zeros(1,Data.nYearsFwd);
        for i = 1:Data.nYearsFwd
            while K(i) <= 0
                K(i) = normrnd(Data.K.mean,Data.K.standard_deviation,1,1);
            end
        end
    case 'AR(1)'
        K = zeros(1,Data.nYearsFwd);
        phi = Data.K.autocorrelation;
        c = Data.K.mean*(1-phi);
        sigma_e = Data.K.standard_deviation*sqrt(1-phi^2);
        
        while K(1) <= 0
            K(1) = normrnd(Data.K.mean,Data.K.standard_deviation,1,1);
            for i = 2:Data.nYearsFwd
                while K(i) <= 0
                    K(i) = c + phi*K(i-1) + normrnd(0,sigma_e,1,1);
                end
            end
        end
end
Data.K.values = K;

% is fish guild catchable or not
Data.catchable = vertcat(Data.Guilds(GINFO.iFishGuilds).catchable);

% length-weight parameters for fishes
Data.lw_a = vertcat(Data.Guilds(GINFO.iFishGuilds).lw_a);
Data.lw_b = vertcat(Data.Guilds(GINFO.iFishGuilds).lw_b);

% von-Bertalanffy parameters for fishes
if all(isfield(Data.Guilds,{'vb_k','vb_linf','vb_l0'}))
    Data.vb_k = vertcat(Data.Guilds(GINFO.iFishGuilds).vb_k);
    Data.vb_linf = vertcat(Data.Guilds(GINFO.iFishGuilds).vb_linf);
    Data.vb_l0 = vertcat(Data.Guilds(GINFO.iFishGuilds).vb_l0);
end
% Remove unused fields
Data = rmfield(Data,'Guilds');
        
