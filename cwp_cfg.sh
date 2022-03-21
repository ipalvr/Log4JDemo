#!/bin/bash
    set -ex

    # Enter Prisma Cloud URL and Token
    var_url="https://console-master-demo.mweibeler.demo.twistlock.com"
    var_token=""
    # var_vapp_img="nginx:latest"
    var_url="https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/collections?project=Central+Console"
    var_token=
    # var_vul_app_image="fefefe8888/l4s-demo-app:1.0"

    # Stop learning for vulnerable app container
    PROFILE_ID=$(curl -k -X GET -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' "${var_url}/api/v1/profiles/container" | jq -r ' .[] | select(.image == "fefefe8888/l4s-demo-app:1.0") | ._id ')
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"state": "manualActive"}' "${var_url}/api/v1/profiles/container/$PROFILE_ID/learn"

    # Add Collections - Working
<<<<<<< HEAD
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app1","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}/api/v1/collections"
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app2","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app2"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}/api/v1/collections"
=======
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app-1","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}"
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app-2","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-2"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}"

    #Original
    # curl -k -X POST -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app-1","images":["${var.vul_app_image}"],"containers":["vul-app-1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var.pcc_url}/api/v21.08/collections"
    # curl -k -X POST -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app-2","images":["${var.vul_app_image}"],"containers":["vul-app-2"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var.pcc_url}/api/v21.08/collections"

    # add runtime rules
    NEW_RULES='[{"name":"vul-app-2","previousName":"","collections":[{"name":"Log4Shell demo - vul-app-2"}],"advancedProtection":true,"processes":{"effect":"prevent","blacklist":[],"whitelist":[],"checkCryptoMiners":true,"checkLateralMovement":true,"checkParentChild":true,"checkSuidBinaries":true},"network":{"effect":"alert","blacklistIPs":[],"blacklistListeningPorts":[],"whitelistListeningPorts":[],"blacklistOutboundPorts":[],"whitelistOutboundPorts":[],"whitelistIPs":[],"skipModifiedProc":false,"detectPortScan":true,"skipRawSockets":false},"dns":{"effect":"prevent","blacklist":[],"whitelist":[]},"filesystem":{"effect":"prevent","blacklist":[],"whitelist":[],"checkNewFiles":true,"backdoorFiles":true,"skipEncryptedBinaries":false,"suspiciousELFHeaders":true},"kubernetesEnforcement":true,"cloudMetadataEnforcement":true,"wildFireAnalysis":"alert"},{"name":"vul-app-1","previousName":"","collections":[{"name":"Log4Shell demo - vul-app-1"}],"advancedProtection":true,"processes":{"effect":"alert","blacklist":[],"whitelist":[],"checkCryptoMiners":true,"checkLateralMovement":true,"checkParentChild":true,"checkSuidBinaries":true},"network":{"effect":"alert","blacklistIPs":[],"blacklistListeningPorts":[],"whitelistListeningPorts":[],"blacklistOutboundPorts":[],"whitelistOutboundPorts":[],"whitelistIPs":[],"skipModifiedProc":false,"detectPortScan":true,"skipRawSockets":false},"dns":{"effect":"alert","blacklist":[],"whitelist":[]},"filesystem":{"effect":"alert","blacklist":[],"whitelist":[],"checkNewFiles":true,"backdoorFiles":true,"skipEncryptedBinaries":false,"suspiciousELFHeaders":true},"kubernetesEnforcement":true,"cloudMetadataEnforcement":true,"wildFireAnalysis":"alert"}]'
    ALL_RULES=$(curl -k -X GET -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var_url}" | jq --argjson nr "$NEW_RULES" ' .rules = $nr + .rules ')
    curl -k -v -X PUT -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var_url}" -d "$ALL_RULES"


    # add WAAS rule
    # NEW_RULES='[{"name":"vul-app-2","collections":[{"name":"Log4Shell demo - vul-app-2"}],"applicationsSpec":[{"appID":"app-0001","sessionCookieSameSite":"Lax","customBlockResponse":{},"banDurationMinutes":5,"certificate":{"encrypted":""},"tlsConfig":{"minTLSVersion":"1.2","metadata":{"notAfter":"0001-01-01T00:00:00Z","issuerName":"","subjectName":""},"HSTSConfig":{"enabled":false,"maxAgeSeconds":31536000,"includeSubdomains":false,"preload":false}},"dosConfig":{"enabled":false,"alert":{},"ban":{}},"apiSpec":{"endpoints":[{"host":"*","basePath":"*","exposedPort":0,"internalPort":8080,"tls":false,"http2":false}],"effect":"disable","fallbackEffect":"disable","skipLearning":false},"botProtectionSpec":{"userDefinedBots":[],"knownBotProtectionsSpec":{"searchEngineCrawlers":"disable","businessAnalytics":"disable","educational":"disable","news":"disable","financial":"disable","contentFeedClients":"disable","archiving":"disable","careerSearch":"disable","mediaSearch":"disable"},"unknownBotProtectionSpec":{"generic":"disable","webAutomationTools":"disable","webScrapers":"disable","apiLibraries":"disable","httpLibraries":"disable","botImpersonation":"disable","browserImpersonation":"disable","requestAnomalies":{"threshold":9,"effect":"disable"}},"sessionValidation":"disable","interstitialPage":false,"jsInjectionSpec":{"enabled":false,"timeoutEffect":"disable"},"reCAPTCHASpec":{"enabled":false,"siteKey":"","secretKey":{"encrypted":""},"type":"checkbox","allSessions":true,"successExpirationHours":24}},"networkControls":{"advancedProtectionEffect":"alert","subnets":{"enabled":false,"allowMode":true,"fallbackEffect":"alert"},"countries":{"enabled":false,"allowMode":true,"fallbackEffect":"alert"}},"body":{"inspectionSizeBytes":131072},"intelGathering":{"infoLeakageEffect":"alert","removeFingerprintsEnabled":true},"maliciousUpload":{"effect":"disable","allowedFileTypes":[],"allowedExtensions":[]},"csrfEnabled":true,"clickjackingEnabled":true,"sqli":{"effect":"alert","exceptionFields":[]},"xss":{"effect":"alert","exceptionFields":[]},"attackTools":{"effect":"alert","exceptionFields":[]},"shellshock":{"effect":"alert","exceptionFields":[]},"malformedReq":{"effect":"alert","exceptionFields":[]},"cmdi":{"effect":"alert","exceptionFields":[]},"lfi":{"effect":"alert","exceptionFields":[]},"codeInjection":{"effect":"alert","exceptionFields":[]},"remoteHostForwarding":{},"customRules":[{"_id":37,"action":"audit","effect":"prevent"},{"_id":36,"action":"audit","effect":"prevent"}]}]}]'
    # ALL_RULES=$(curl -k -X GET -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/firewall/app/container" | jq --argjson nr "$NEW_RULES" ' .rules = $nr + .rules ')
    # curl -k -X PUT -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/firewall/app/container" -d "$ALL_RULES"
    # enable WildFire
    # curl -k -X PUT -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v1/settings/wildfire" -d '{"region":"sg","runtimeEnabled":true,"complianceEnabled":true,"uploadEnabled":true,"graywareAsMalware":false}'
    # EOF
>>>>>>> 053f47954062a89075d57077cbbf65f15b2821b3
