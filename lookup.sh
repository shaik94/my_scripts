dig $1 +noall +authority +answer
echo ------------------------------------------------------------------dns-sydney------------------------------------------------------------------
host  $1  dns-sydney.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-sydney.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-sydney.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-hkk------------------------------------------------------------------
host  $1  dns-hkk.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-hkk.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-hkk.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-singapore------------------------------------------------------------------
host  $1  dns-singapore.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-singapore.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-singapore.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-blr1------------------------------------------------------------------
host  $1  dns-blr1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-blr1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-blr1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-blr2------------------------------------------------------------------
host  $1  dns-blr2.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-blr2.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-blr2.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-tokyo------------------------------------------------------------------
host  $1  dns-tokyo.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-tokyo.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-tokyo.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-aer1------------------------------------------------------------------
host  $1  dns-aer1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-aer1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-aer1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-ams------------------------------------------------------------------
host  $1  dns-ams.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-ams.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-ams.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-sj------------------------------------------------------------------
host  $1  dns-sj.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-sj.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-sj.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-rtp------------------------------------------------------------------
host  $1  dns-rtp.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-rtp.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-rtp.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-bxb------------------------------------------------------------------
host  $1  dns-bxb.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-bxb.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-bxb.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-mtv------------------------------------------------------------------
host  $1  dns-mtv.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-mtv.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-mtv.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-aln1------------------------------------------------------------------
host  $1  dns-aln1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-aln1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-aln1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-aln2------------------------------------------------------------------
host  $1  dns-aln2.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-aln2.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-aln2.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-rch1------------------------------------------------------------------
host  $1  dns-rch1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-rch1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-rch1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-rch2------------------------------------------------------------------
host  $1  dns-rch2.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-rch2.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-rch2.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-yow1------------------------------------------------------------------
host  $1  dns-yow1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-yow1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-yow1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
echo ------------------------------------------------------------------dns-jrs1------------------------------------------------------------------
host  $1  dns-jrs1.cisco.com | egrep "has address" | awk '{print $4}'
host  $1  dns-jrs1.cisco.com | egrep "has IPv6 address" | awk '{print $5}'
host `host  $1  dns-jrs1.cisco.com | egrep "has address" | awk '{print $4}'`  | awk '{print $5}'
