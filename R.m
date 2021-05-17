function value=R(alpha,ax,ay,aMax,aMin)

    value=max(0,1-alpha*(abs(ax-ay)/(aMax-aMin)));

end