Name:           viewer
Version:        0.4
Release:        %(date +%Y%m%d%H)%{?dist}
Summary:        viewer of LAA Competition tracks

Group:          Applications/Internet
License:        BUT LICENCE (GPLv2 compatibile)
URL:            https://github.com/DCGM/LAA-maps-viewer
Source0:        https://github.com/DCGM/LAA-maps-viewer/archive/master.tar.gz#/%{name}-%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  qt5-qtbase-devel
BuildRequires:  qt5-qtquickcontrols
BuildRequires:  qt5-qtdeclarative-devel
BuildRequires:  qt5-qtcharts-devel
BuildRequires:  qt5-linguist
BuildRequires:  git
BuildRequires:  cmake

%description
viewer is tool for viewing of LAA Competion tracks

%prep
%setup -q -n %{name}-%{version}


%build
%cmake
make %{?_smp_mflags}

%install
make DESTDIR=%{buildroot} install
desktop-file-validate %{buildroot}%{_datadir}/applications/%{name}.desktop


%files
%dir %{_datadir}/viewer
%{_bindir}/viewer
%{_datadir}/applications/viewer.desktop
%{_datadir}/icons/hicolor/applications/64x64/viewer64.ico
%{_datadir}/icons/hicolor/applications/64x64/viewer64.png
%{_datadir}/viewer/i18n/viewer_cs_CZ.qm
%{_datadir}/viewer/i18n/viewer_en_US.qm


%changelog
* Fri Jun 15 2018 Jozef Mlich <imlich@fit.vutbr.cz> - 0.2.0-1
- initial packaging

