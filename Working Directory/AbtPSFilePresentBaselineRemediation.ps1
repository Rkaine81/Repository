if (test-path \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK) {

    if (!(test-path C:\Apps\AbtPS)) {New-Item -ItemType Directory -Path C:\Apps -Name AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\HP)) {New-Item -ItemType Directory -Path C:\Apps\AbtPS -Name HP -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_2.0)) {New-Item -ItemType Directory -Path C:\Apps\AbtPS\HP -Name CmpTrWmi_2.0 -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0)) {New-Item -ItemType Directory -Path C:\Apps\AbtPS\HP -Name CmpTrWmi_3.0 -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64)) {New-Item -ItemType Directory -Path C:\Apps\AbtPS\HP -Name CmpTrWmi_3.0_64 -Force}
    if (!(test-path C:\Apps\AbtPS\AbtPaaSTest.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\AbtPaaSTest.dll C:\Apps\AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\AbtPersStatusReport.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\AbtPersStatusReport.dll C:\Apps\AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\AbtPersStatusReport64.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\AbtPersStatusReport64.dll C:\Apps\AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\AbtPS.exe)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\AbtPS.exe C:\Apps\AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\readme.txt)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\readme.txt C:\Apps\AbtPS -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_2.0\CmpTrWmi.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\HP\CmpTrWmi_2.0\CmpTrWmi.dll C:\Apps\AbtPS\HP\CmpTrWmi_2.0 -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0\CmpTrWmi.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\HP\CmpTrWmi_3.0\CmpTrWmi.dll C:\Apps\AbtPS\HP\CmpTrWmi_3.0 -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64\CmpTrWmi.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\HP\CmpTrWmi_3.0_64\CmpTrWmi.dll C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64 -Force}
    if (!(test-path C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64\CmpTrWmi64.dll)) {copy-item \\choa-cifs\install\CM_P01\06_InProduction\SoftwareDistribution\CHOA\AbtPS_SDK\HP\CmpTrWmi_3.0_64\CmpTrWmi64.dll C:\Apps\AbtPS\HP\CmpTrWmi_3.0_64 -Force}

}