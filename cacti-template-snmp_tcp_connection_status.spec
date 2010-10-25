# TODO
# - release modifications upstream/forum
%define		template	snmp_tcp_connection_status
Summary:	TCP Connection Status template for Cacti
Name:		cacti-template-%{template}
Version:	0.2
Release:	2
License:	GPL v2
Group:		Applications/WWW
# Source0Download: http://forums.cacti.net/download.php?id=5198
Source0:	tcp-connections.zip
# Source0-md5:	72fd9adfafcecec0b6f5a23ec6db8e57
Source1:	%{name}.sh
Source2:	tcpstat
URL:		http://forums.cacti.net/viewtopic.php?t=12766
BuildRequires:	rpmbuild(macros) >= 1.554
BuildRequires:	sed >= 4.0
BuildRequires:	unzip
Requires:	cacti >= 0.8.7e-9
Requires:	net-snmp-utils
Obsoletes:	cacti-plugin-snmp_tcp_connection_status
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		cactidir		/usr/share/cacti
%define		resourcedir		%{cactidir}/resource
%define		scriptsdir		%{cactidir}/scripts
%define		snmpdconfdir	/etc/snmp
%define		_libdir			%{_prefix}/lib
# This is officially registered: http://www.oid-info.com/get/1.3.6.1.4.1.16606
%define		snmpoid			.1.3.6.1.4.1.16606.1

%description
Template for Cacti - Monitor TCP Connection Status.

This is improved version which uses SNMPd server side calculation
instead of fetching all data over slow SNMP protocol.

You need net-snmp-agent-tcpstat installed on SNMP server side.

%package -n net-snmp-agent-tcpstat
Summary:	SNMPd agent to provide TCP Connection statistics
Group:		Networking/Daemons
Requires:	awk
Requires:	iproute2
Requires:	net-snmp

%description -n net-snmp-agent-tcpstat
SNMPd agent to provide TCP Connection statistics.

%prep
%setup -qc
%{__sed} -i -e 's,/bin/bash /var/www/htdocs/cacti/scripts/get_tcp_connections,%{scriptsdir}/%{template},' *.xml

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{resourcedir},%{scriptsdir},%{snmpdconfdir},%{_libdir}}
cp -a *.xml $RPM_BUILD_ROOT%{resourcedir}
install -p %{SOURCE1} $RPM_BUILD_ROOT%{scriptsdir}/%{template}
install -p %{SOURCE2} $RPM_BUILD_ROOT%{_libdir}/snmpd-agent-tcpstat

%post
%cacti_import_template %{resourcedir}/cacti_graph_template_tcp_connections.xml

%post -n net-snmp-agent-tcpstat
if ! grep -qF %{snmpoid} %{snmpdconfdir}/snmpd.local.conf; then
	echo "extend %{snmpoid} tcpstat %{_libdir}/snmpd-agent-tcpstat" >> %{snmpdconfdir}/snmpd.local.conf
	%service -q snmpd reload
fi

%preun -n net-snmp-agent-tcpstat
if [ "$1" = 0 ]; then
	if [ -f %{snmpdconfdir}/snmpd.local.conf ]; then
		%{__sed} -i -e "/extend %(echo %{snmpoid} | sed -e 's,\.,\\.,g')/d" %{snmpdconfdir}/snmpd.local.conf
		%service -q snmpd reload
	fi
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{scriptsdir}/%{template}
%{resourcedir}/cacti_graph_template_tcp_connections.xml

%files -n net-snmp-agent-tcpstat
%defattr(644,root,root,755)
%attr(755,root,root) %{_libdir}/snmpd-agent-tcpstat
