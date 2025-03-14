set ns [new Simulator] 
set namfile [open CN11B.nam w]
set tracefile [open CN11B.tr w]
$ns trace-all $tracefile
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile 1500 1500

set topo [new Topography]
$topo load_flatgrid 1500 1500

proc Finish {} {
    global ns namfile tracefile
    $ns flush-trace
    close $namfile
    close $tracefile
    exec nam CN11B.nam &
    exec echo "The number of packets dropped is : " &
    exec grep -c "^d" CN11B.tr &
    exit 0
}

$ns node-config -adhocRouting DSDV \
                -llType LL \
                -macType Mac/802_11 \
                -ifqType Queue/DropTail \
                -ifqLen 20 \
                -phyType Phy/WirelessPhy \
                -channelType Channel/WirelessChannel \
                -propType Propagation/TwoRayGround \
                -antType Antenna/OmniAntenna \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \

create-god 6

set n0 [$ns node]
$n0 set X_ 600
$n0 set Y_ 500
$n0 set Z_ 0
$ns initial_node_pos $n0 20

set n1 [$ns node]
$n1 set X_ 400
$n1 set Y_ 300
$n1 set Z_ 0
$ns initial_node_pos $n1 20

set n2 [$ns node]
$n2 set X_ 800
$n2 set Y_ 300
$n2 set Z_ 0
$ns initial_node_pos $n2 20

set n3 [$ns node]
$n3 set X_ 300
$n3 set Y_ 200
$n3 set Z_ 0
$ns initial_node_pos $n3 20

set n4 [$ns node]
$n4 set X_ 500
$n4 set Y_ 100
$n4 set Z_ 0
$ns initial_node_pos $n4 20

set n5 [$ns node]
$n5 set X_ 1000
$n5 set Y_ 200
$n5 set Z_ 0
$ns initial_node_pos $n5 20

set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null0 [new Agent/Null]
$ns attach-agent $n4 $null0
$ns connect $udp $null0
$udp set packetSize_ 1500

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 1000
$cbr set rate_ 1Mb
$cbr set random_ false

set tcp [new Agent/TCP]
$ns attach-agent $n3 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n5 $sink
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 1.0 "$cbr start"
$ns at 2.0 "$ftp start"
$ns at 180.0 "$ftp stop"
$ns at 200.0 "$cbr stop"
$ns at 200.0 "Finish"
$ns at 70.0 "$n4 setdest 100 60 20"
$ns at 100.0 "$n4 setdest 700 300 20"
$ns at 150.0 "$n4 setdest 900 200 20"

$ns run
