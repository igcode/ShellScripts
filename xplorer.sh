#!/bin/bash

### Acts like a data gateway between the Webtool with no access data  ###
### but visual to our own monitoring tools with eligible data format  ###

# programs #

CURL="/usr/bin/curl";
CAT="/bin/cat";
GREP="/bin/grep";
PERL="/usr/bin/perl";
AWK="/usr/bin/awk";

# end programs #

# connection details #

user="user";
pass="password";
ip="0.0.0.0";

# end connection details # 

# files #

cookie=$HOME/scripts/xplorer.cookie
dumpf=$HOME/scripts/xplorer.out
testcase=$HOME/scripts/xplorer.testcase

# end files #


# I get the session cookies so I can navigate through the different web views

$CURL -s -c $cookie -d "__VIEWSTATE=%2FwEPDwUJNTUzOTk5ODE2ZGRHr4xQQqODGV%2BUcpOpP3lSr7J6ww%3D%3D&usuario=$user&password=$pass&accion=login" -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.8) Gecko/20071004 Iceweasel/2.0.0.8 (Debian-2.0.0.6+2.0.0.8-0etch1)" -H "Referer: http://$ip/EisReports/" -i "http://$ip/Reports/default.aspx" > /dev/null

# extracts the cookies from the dumped cookie file

ASPId=`$CAT $cookie | $GREP ASP.NET_SessionId | $AWK '{print $7}'`;

AuthCookie=`$CAT $cookie | $GREP AuthCookie | $AWK '{print $7}'`;

# Request the Alarm events page in html format

$CURL -s -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.8) Gecko/20071004 Iceweasel/2.0.0.8 (Debian-2.0.0.6+2.0.0.8-0etch1)" -H "Cookie: ASP.NET_SessionId=$ASPId;AuthCookie=$AuthCookie" -i "http://$ip/Reports/alert/events/viewevents.aspx" > $dumpf


# Extract using R.E. from the html and save the data in $testcase file using the desired format:

# Test Case Id # Probe Unit # start date alarm # Severity Alarm # Alarm Description

$CAT $out | $PERL -wlne 'print "$1#$2#$3#$4#$5" if /.*<a class=\"link\" href=\"\/Reports\/Reports\/RealTime\/reportView\.aspx\?idTestCase=.*\">(.*)<\/a>.*Probe Unit.*>(.*)<\/td>.*class=\"SeverityAlarm(\d+)(\w+)\".*>(.*)<\/td>.*/' > $testcase;

