R_PIPE5 = 4.127E-4;
q=0:20:200;
headloss = R_PIPE5*q.^1.852;
plot(q,headloss)
rela = [q' headloss']