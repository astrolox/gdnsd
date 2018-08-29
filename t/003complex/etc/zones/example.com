@	SOA ns1 hmaster.example.net. (
	1      ; serial
	7200   ; refresh
	1800   ; retry
	259200 ; expire
        900    ; ncache
)

; Basic NS records (required)
@()		NS	ns1
@		(NS)	ns2
ns1		( A	192.0.2.1 )
ns2		A	(192.0.2.2		
)

; subzone w/ NS records that are in our zone and not the subzone, no glue (not allowed)
subeasy		IN (NS ; single-line comment within ( ) multi-line record
			subeasyns1)
subeasy		NS subeasyns2
subeasyns1	A	192.0.2.3
subeasyns2(
A
192.0.2.4
			)

; subzone w/ NS records that are inside itself, with (required) glue
subhard		NS	ns1.subhard
subhard		21600 NS	ns2.subhard
ns1.subhard	A	192.0.2.5
ns1.subhard	A	192.0.2.55
ns2.subhard	A	192.0.2.6

; subzone w/ NS records in a totally unrelated domain that we don't serve, without glue
subext		21600 IN NS	ns-subext1.example.net.
subext		NS	ns-subext2.example.net.

; subzone w/ NS records in an unrelated domain that we *do* serve
;  these will be handled as follows:
;  1) If specified as out-of-zone glue in this file, we use that
;   1a) If ooz def here doesn't match the real zonefile, warn about it
;  2) If not, no address given
subsemiext	IN 21600 NS	ns1.example.org.
subsemiext	NS	ns2.example.org.
subsemiext	NS	ns3.*.example.org. ; using * to skip wildcard...
subsemiext	NS	ns4.example.org. ; no glue provided for this
ns1.example.org. A	192.0.2.200 ; overlaps real example.org, same addr
ns2.example.org. A	192.0.2.207 ; overlaps real example.org, diff addr
ns3.*.example.org. A	192.0.2.209 ; no record in example.org

; subzone that mixes all of the above in one go:
subfubar	NS	subeasyns1
subfubar	NS	ns1.subfubar
ns1.subfubar	A	192.0.2.9
subfubar	NS	ns-subfubar1.example.net.
subfubar	NS	ns1.example.org.

; And again, but as a deeper subzone
subfubar.x.y.z	NS	subeasyns1
subfubar.x.y.z	NS	ns1.subfubar.x.y.z
ns1.subfubar.x.y.z A	192.0.2.11
subfubar.x.y.z	NS	ns-subfubarxyz1.example.net.
subfubar.x.y.z	NS	ns1.example.org.

; glue address at delegation point itself
subselfglue	A	192.0.2.12
subselfglue	NS	subselfglue

; out-of-zone glue - domain not known locally
subooz		NS	ns1.example.net.
subooz		NS	ns2.example.net.
ns1.example.net. A	192.0.2.77
ns2.example.net. A	192.0.2.78
ns2.example.net. AAAA	2001:DB8::1

; mixed out-of-zone glue
submixooz	NS	ns1.example.net.
submixooz	NS	ns1.submixooz
ns1.submixooz	A	192.0.2.79

; 5x A + 0x AAAA (for dnspacket v4a logic)
five-a A 192.0.2.131
five-a A 192.0.2.132
five-a A 192.0.2.133
five-a A 192.0.2.134
five-a A 192.0.2.135

; CNAME torture
; 4-level to an A record
ct1	CNAME	ct2
ct2	CNAME	ct3
ct3	CNAME	ct4
ct4	CNAME	foo

; 4-level to the outside
ctx1	CNAME	ctx2
ctx2	CNAME	ctx3
ctx3	CNAME	ctx4
ctx4	CNAME	www.example.net.

; jump between local zones
ct21	CNAME	ct22.example.org.

; CNAME that points into a delegated subzone
ctinside	CNAME	www.subfubar.x.y.z

; additional data in other auth domain
mxinorg		MX	0	foo.example.org.

; addr rrset limit tests
$ADDR_LIMIT_V4 3
$ADDR_LIMIT_V6 4
setlimit	A	192.0.2.177
setlimit	A	192.0.2.178
setlimit	A	192.0.2.179
setlimit	A	192.0.2.180
setlimit	A	192.0.2.181
setlimit	A	192.0.2.182
setlimit	AAAA	::1
setlimit	AAAA	::2
setlimit	AAAA	::3
setlimit	AAAA	::4
setlimit	AAAA	::5
setlimit	AAAA	::6
$ADDR_LIMIT_V4 5
$ADDR_LIMIT_V6 6
setlimit-under	A	192.0.2.108
setlimit-under	A	192.0.2.109
setlimit-under	A	192.0.2.110
setlimit-under	AAAA	::108
setlimit-under	AAAA	::109
setlimit-under	AAAA	::110
$ADDR_LIMIT_V4 1
$ADDR_LIMIT_V6 1
setlimit-one	A	192.0.2.118
setlimit-one	A	192.0.2.119
setlimit-one	A	192.0.2.120
setlimit-one	AAAA	::118
setlimit-one	AAAA	::119
setlimit-one	AAAA	::120
$ADDR_LIMIT_V4 0
$ADDR_LIMIT_V6 0

; compression torture-test names
foo.compression-torture.foo	MX	0 foo.foo.foo.fox
foo.compression-torture.foo	MX	1 fox
foo.compression-torture.foo	MX	2 bar.foo.foo.foo
foo.compression-torture.foo	MX	3 fox.foo
foo.compression-torture.foo	MX	4 foo.fooo.foo.fo
foo.compression-torture.foo	MX	5 foo.fox
foo.compression-torture.foo	MX	6 fox.foo.foo.foo
foo.compression-torture.foo	MX	7 foo.foo.foo
foo.compression-torture.foo	MX	8 foo.fox.foo.foo
foo.compression-torture.foo	MX	9 foo.foo.foo.foo
foo.compression-torture.foo	MX	10 foo.foo.foo.bar
foo.compression-torture.foo	MX	11 foo.foo
foo.compression-torture.foo	MX	12 fo.foo.foo.fooo
foo.compression-torture.foo	MX	13 foo
foo.compression-torture.foo	MX	14 asdf.xyz.foo.foo.fox.foo.example.org.
foo.compression-torture.foo	MX	15 foo.foo.bar.foo
foo.compression-torture.foo	MX	16 fooo.foo.foo.fo
foo.compression-torture.foo	MX	17 foo.fox.foo
foo.compression-torture.foo	MX	18 foo.foo.fooo.fo
foo.compression-torture.foo	MX	19 foo.foo.fox.foo
foo		A	192.0.2.160
fox		A	192.0.2.161
foo.foo		A	192.0.2.162
fox.foo		A	192.0.2.163
foo.fox		A	192.0.2.164
foo.foo.foo	A	192.0.2.165
foo.fox.foo	A	192.0.2.166
foo.foo.foo.foo	A	192.0.2.167
foo.foo.foo.bar A	192.0.2.168
bar.foo.foo.foo A	192.0.2.169
foo.foo.bar.foo A	192.0.2.170
fooo.foo.foo.fo A	192.0.2.171
foo.foo.fooo.fo A	192.0.2.172
foo.fooo.foo.fo A	192.0.2.173
fo.foo.foo.fooo A	192.0.2.174
foo.foo.fox.foo A	192.0.2.175
foo.fox.foo.foo A	192.0.2.176
fox.foo.foo.foo A	192.0.2.177
foo.foo.foo.fox A	192.0.2.178

; NAPTRs + associated AD
naptr-u NAPTR 100 10 "U" "E2U+sip" "!^.*$!sip:customer-service@example.com!i" .
naptr-u NAPTR 102 10 "U" "E2U+email" "!^.*$!mailto:information@example.com!i" .
naptr-s NAPTR 100 10 "S" "SIP+D2U" "" _sip._udp
naptr-s NAPTR 102 10 "S" "SIP+D2T" "" _sip._tcp
naptr-a NAPTR 100 10 "A" "SIP+D2U" "" naptr-udp-foo
naptr-a NAPTR 101 10 "A" "SIP+D2U" "" naptr-udp-bar
naptr-a NAPTR 102 10 "A" "SIP+D2T" "" naptr-tcp-foo
naptr-a NAPTR 103 10 "A" "SIP+D2T" "" naptr-tcp-bar
naptr-sx NAPTR 100 10 "S" "+FOO:BAR" "" somewhere.example.net.
_sip._udp SRV 10 60 5060 naptr-udp-foo
_sip._udp SRV 10 20 5060 naptr-udp-bar
_sip._tcp SRV 10 60 5060 naptr-tcp-foo
_sip._tcp SRV 10 20 5060 naptr-tcp-bar
naptr-udp-foo A 192.0.2.180
naptr-udp-foo A 192.0.2.181
naptr-udp-bar AAAA ::1
naptr-udp-bar AAAA ::2
naptr-tcp-foo A 192.0.2.182
naptr-tcp-foo AAAA ::3
naptr-tcp-bar A 192.0.2.183

; NAPTR+SRV+A all at the same name with self-reference, to check an ANY query
;  and some of the additional data handling logic
nsa NAPTR 100 10 "S" "foo" "" nsa
nsa NAPTR 101 10 "A" "foo" "" nsa
nsa SRV 10 20 30 nsa
nsa A 192.0.2.185

; min/max various numeric data types
minip	A	0.0.0.0
maxip	A	255.255.255.255
minmx	MX	0	foo
maxmx	MX	65535	foo
minsrv	SRV	0 0 0 foo
maxsrv	SRV	65535 65535 65535 foo
255.255.255.255	PTR	foo
0.0.0.0	PTR	foo
minttl	0		A	192.0.2.199
maxttl	2147483647	IN	A	192.0.2.199

; flags [SAUP] are mutex and duplicate flags are not allowed,
; which limits the flags field len (we use 'p' here)
min-naptr NAPTR 0 0 "" "" "" .
max-naptr NAPTR 65535 65535 bcdefghijklmnopqrtvwxyz0123456789 a+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z+z 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234 .
max-naptr2 NAPTR 65535 65535 bcdefghijklmnopqrtvwxyz0123456789 A0123456789012345678901234567890+A0123456789012345678901234567890+A0123456789012345678901234567890+A0123456789012345678901234567890+A0123456789012345678901234567890+A0123456789012345678901234567890+A0123456789012345678901234567890+A01234567890123456789012 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234 .

; RFC3597 encoding of a pair of made-up 31337 rrtypes and a pair
;   of SSHFP RRs using 20-byte SHA-1 fingerprints
rfc3597 TYPE31337 \# 10 0123456789ABCDEF0123
rfc3597 TYPE31337 \# 10 3210FEDCBA 9876543210;close comment
rfc3597 TYPE44 \# 22 01 01 012345 6789ABCDEF0123456789ABCDEF01234567 ; spaced comment
rfc3597 TYPE44 \# 22 02 01 0123456789ABCDEF0123456789AB CDEF01234567	; tabbed comment

; mixed-case zonefile input should get normalized
MiXeD	MX	0	MaXTTL

; Some AAAA-related things
v6basic	1234	AAAA	1234:5678:90AB:CDEF:FDEC:BA09:8765:4321
v6minmax	AAAA	FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF
v6minmax	AAAA	::1
v6minmax	AAAA	::
46mix		A	192.0.2.200
46mix		AAAA	ABCD::DCBA
46mix		A	192.0.2.201
46mix		AAAA	DEAD::BEEF
46deleg		NS	v6minmax
46deleg		NS	46mix
46deleg		NS	v6basic
46glue		NS	a.46glue
a.46glue	A	192.0.2.202
a.46glue	A	192.0.2.203
46glue		NS	b.46glue
b.46glue	AAAA	::1
b.46glue	AAAA	::0.0.0.2
b.46glue	AAAA	::3
46glue		NS	c.46glue
c.46glue	A	192.0.2.204
c.46glue	AAAA	::4
c.46glue	A	192.0.2.205
46glue		NS	d.46glue
d.46glue	AAAA	::5
d.46glue	A	192.0.2.206
d.46glue	AAAA	::6
v6mx		MX	0 v6basic
_smtp._tcp	SRV	1 2 3 46mix

012345678901234567890123456789012345678901234567890123456789.012345678901234567890123456789012345678901234567890123456789.012345678901234567890123456789012345678901234567890123456789.big64mx MX	0 01234567890.big46
01234567890.big46		AAAA	::1
01234567890.big46		AAAA	::2
01234567890.big46		AAAA	::3
01234567890.big46		AAAA	::4
01234567890.big46		AAAA	::5
01234567890.big46		AAAA	::6
01234567890.big46		AAAA	::7
01234567890.big46		AAAA	::8
01234567890.big46		AAAA	::9
01234567890.big46		AAAA	::A
01234567890.big46		A	192.0.2.220
01234567890.big46		A	192.0.2.221
01234567890.big46		A	192.0.2.222
01234567890.big46		A	192.0.2.223
01234567890.big46		A	192.0.2.224
01234567890.big46		A	192.0.2.225
01234567890.big46		A	192.0.2.226

; Giant MX recordset w/ associated A records, for TC-bit/EDNS/TCP/etc testing
big	MX	0	asdf
big	MX	1	asdff
big	MX	2	asdfff
big	MX	3	asdffff
big	MX	4	asdfffff
big	MX	5	asdffffff
big	MX	6	asdfffffff
big	MX	7	asdffffffff
big	MX	8	asdfffffffff
big	MX	9	asdffffffffff
big	MX	10	asdfffffffffff
big	MX	11	asdffffffffffff
big	MX	12	asdfffffffffffff
big	MX	13	asdffffffffffffff
big	MX	14	asdfffffffffffffff
big	MX	15	asdffffffffffffffff
big	MX	16	asdfffffffffffffffff
big	MX	17	asdffffffffffffffffff
big	MX	18	asdfffffffffffffffffff
big	MX	19	asdffffffffffffffffffff
big	MX	20	asdfffffffffffffffffffff
asdfffffffffffffffffffff	A	192.0.2.50
asdffffffffffffffffffff	A	192.0.2.51
asdfffffffffffffffffff	A	192.0.2.52
asdffffffffffffffffff	A	192.0.2.53
asdfffffffffffffffff	A	192.0.2.54
asdffffffffffffffff	A	192.0.2.55
asdfffffffffffffff	A	192.0.2.56
asdffffffffffffff	A	192.0.2.57
asdfffffffffffff	A	192.0.2.58
asdffffffffffff	A	192.0.2.59
asdfffffffffff	A	192.0.2.60
asdffffffffff	A	192.0.2.61
asdfffffffff	A	192.0.2.62
asdffffffff	A	192.0.2.63
asdfffffff	A	192.0.2.64
asdffffff	A	192.0.2.65
asdfffff	A	192.0.2.66
asdffff	A	192.0.2.67
asdfff	A	192.0.2.68
asdff	A	192.0.2.69
asdf	A	192.0.2.70

; An even bigger one (exceeds ethernet MTU)
vbig	MX	0	vasdf
vbig	MX	1	vasdff
vbig	MX	2	vasdfff
vbig	MX	3	vasdffff
vbig	MX	4	vasdfffff
vbig	MX	5	vasdffffff
vbig	MX	6	vasdfffffff
vbig	MX	7	vasdffffffff
vbig	MX	8	vasdfffffffff
vbig	MX	9	vasdffffffffff
vbig	MX	10	vasdfffffffffff
vbig	MX	11	vasdffffffffffff
vbig	MX	12	vasdfffffffffffff
vbig	MX	13	vasdffffffffffffff
vbig	MX	14	vasdfffffffffffffff
vbig	MX	15	vasdffffffffffffffff
vbig	MX	16	vasdfffffffffffffffff
vbig	MX	17	vasdffffffffffffffffff
vbig	MX	18	vasdfffffffffffffffffff
vbig	MX	19	vasdffffffffffffffffffff
vbig	MX	20	vasdfffffffffffffffffffff
vbig	MX	21	vasdffffffffffffffffffffff
vbig	MX	22	vasdfffffffffffffffffffffff
vbig	MX	23	vasdffffffffffffffffffffffff
vbig	MX	24	vasdfffffffffffffffffffffffff
vbig	MX	25	vasdffffffffffffffffffffffffff
vbig	MX	26	vasdfffffffffffffffffffffffffff
vbig	MX	27	vasdffffffffffffffffffffffffffff
vbig	MX	28	vasdfffffffffffffffffffffffffffff
vbig	MX	29	vasdffffffffffffffffffffffffffffff
vbig	MX	30	vasdfffffffffffffffffffffffffffffff

vasdfffffffffffffffffffffffffffffff	A	192.0.2.100
vasdffffffffffffffffffffffffffffff	A	192.0.2.101
vasdfffffffffffffffffffffffffffff	A	192.0.2.102
vasdffffffffffffffffffffffffffff	A	192.0.2.103
vasdfffffffffffffffffffffffffff	A	192.0.2.104
vasdffffffffffffffffffffffffff	A	192.0.2.105
vasdfffffffffffffffffffffffff	A	192.0.2.106
vasdffffffffffffffffffffffff	A	192.0.2.107
vasdfffffffffffffffffffffff	A	192.0.2.108
vasdffffffffffffffffffffff	A	192.0.2.109
vasdfffffffffffffffffffff	A	192.0.2.110
vasdffffffffffffffffffff	A	192.0.2.111
vasdfffffffffffffffffff	A	192.0.2.112
vasdffffffffffffffffff	A	192.0.2.113
vasdfffffffffffffffff	A	192.0.2.114
vasdffffffffffffffff	A	192.0.2.115
vasdfffffffffffffff	A	192.0.2.116
vasdffffffffffffff	A	192.0.2.117
vasdfffffffffffff	A	192.0.2.118
vasdffffffffffff	A	192.0.2.119
vasdfffffffffff	A	192.0.2.120
vasdffffffffff	A	192.0.2.121
vasdfffffffff	A	192.0.2.122
vasdffffffff	A	192.0.2.123
vasdfffffff	A	192.0.2.124
vasdffffff	A	192.0.2.125
vasdfffff	A	192.0.2.126
vasdffff	A	192.0.2.127
vasdfff	A	192.0.2.128
vasdff	A	192.0.2.129
vasdf	A	192.0.2.130

; LHS is 255 bytes long using few max-sized labels to get there (don't forget implicit example.com)
aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeee	A	192.0.2.150

; Like above, but on both the right and left sides (fully-qualified in the RHS case), and the RHS refs the above name
xaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeee	MX	1	aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg.aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeee.example.com.

; LHS is in-domain so it's not quite 127 labels, but it is 255 bytes.
; We use an external fictitious name for the RHS that fully utilizes 127 labels for 255 bytes.
; Note the "Z" labels at the ends - this is to avoid Net::DNS being "smart" and thinking these are ip addresses... :P
0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.Z MX 1 0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.6.7.8.9.0.1.2.3.4.5.Z.

; 255 byte 
; Text limits

mintxt	TXT	""
min255txt	TXT	"" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
max1txt	TXT	012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234

; 255 bytes of repeating digit sequences, following by 32 bytes of 9's.
split-txt TXT	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123499999999999999999999999999999999

; There is a giant TXT record below, which is hard to see in a normal text
; editor in a terminal window: its name is "max63txt", and its data is 62x
; 255-byte TXT chunks, followed by a final 127-byte txt chunk. This puts the
; final rdata length in the packet at exactly the 16000 limit.

max63txt TXT "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456"
