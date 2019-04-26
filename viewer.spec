Name:           viewer
Version:        0.4
Release:        %(date +%Y%m%d%H)%{?dist}
Summary:        viewer of LAA Competition tracks

Group:          Applications/Internet
License:        BUT LICENCE (GPLv2 compatibile)
URL:            https://github.com/DCGM/LAA-maps-viewer
Source0:        https://github.com/DCGM/LAA-maps-viewer/archive/master.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  qt5-devel >= 5.10.0
BuildRequires:  qt5-qtcharts-devel
BuildRequires:  qt5-linguist

%description
viewer is tool for viewing of LAA Competion tracks

%prep
%setup -q -n %{name}-%{version}


%build
%{qmake_qt5} PREFIX=%{_prefix}
make %{?_smp_mflags}

%install
make INSTALL_ROOT=$RPM_BUILD_ROOT install
desktop-file-install --dir=${RPM_BUILD_ROOT}%{_datadir}/applications %{name}.desktop


%files
%{_bindir}/viewer
%{_datadir}/applications/viewer.desktop
%{_datadir}/icons/hicolor/64x64/apps/viewer64.png
%{_datadir}/viewer/i18n/viewer_cs_CZ.qm
%{_datadir}/viewer/i18n/viewer_en_US.qm

#/opt/viewer/*


%changelog
* Fri Jun 15 2018 Jozef Mlich <imlich@fit.vutbr.cz> - 0.2.0-1
- initial packaging

