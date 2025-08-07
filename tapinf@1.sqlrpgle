**free
ctl-opt option(*nodebugio: *srcstmt) dftactgrp(*no) debug(*yes);

dcl-f tapdspf workstn indds(tapindds) sfile(SFLR01:RRN#);

dcl-ds tapindds qualified;
    exit ind pos(3);
    refresh ind pos(5);
    sfldspctl ind pos(30);
    sfldsp ind pos(31);
end-ds;

dcl-f tapinf extname('DDSCBK/TAPINF') qualified;
end-ds;
