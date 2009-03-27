# TODO
# - release modifications upstream/forum
%define		template	snmp_tcp_connection_status
Summary:	TCP Connection Status template for Cacti
Name:		cacti-template-%{template}
Version:	0.1
Release:	1
License:	GPL v2
Group:		Applications/WWW
# Source0Download: http://forums.cacti.net/download.php?id=5198
Source0:	tcp-connections.zip
# Source0-md5:	72fd9adfafcecec0b6f5a23ec6db8e57
Source1:	%{name}.sh
URL:		http://forums.cacti.net/viewtopic.php?t=12766
BuildRequires:	sed >= 4.0
Requires:	cacti >= 0.8.6j
Requires:	cacti-add_template
Requires:	net-snmp-utils
Obsoletes:	cacti-plugin-snmp_tcp_connection_status
BuildArch:	noarch
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%define		cactidir		/usr/share/cacti
%define		resourcedir		%{cactidir}/resource
%define		scriptsdir		%{cactidir}/scripts

%description
Template for Cacti - Monitor TCP Connection Status.

%prep
%setup -q -c
mv get_tcp_connections{,.orig}
install %{SOURCE1} get_tcp_connections
%{__sed} -i -e 's,/bin/bash /var/www/htdocs/cacti/scripts/get_tcp_connections,%{scriptsdir}/%{template},' *.xml

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT{%{resourcedir},%{scriptsdir}}
cp -a *.xml $RPM_BUILD_ROOT%{resourcedir}
install get_tcp_connections $RPM_BUILD_ROOT%{scriptsdir}/%{template}

%post
%{_sbindir}/cacti-add_template %{resourcedir}/cacti_graph_template_tcp_connections.xml

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{scriptsdir}/%{template}
%{resourcedir}/cacti_graph_template_tcp_connections.xml
