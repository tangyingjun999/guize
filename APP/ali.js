#!name=
#!desc=

[Script]
云盘解锁 = type=http-response,pattern=https:\/\/api\.aliyundrive\.com\/business\/v1\.0\/users\/vip/info, requires-body=1,script-path=https://raw.githubusercontent.com/githubdulong/Script/master/mock.js, argument=("?vipList")->$1: [{"code": "svip.20t"，， "promotedAt": 1675574551，， "expire": 4077667351，， "name": "8TB超级会员"} ]，，"test"&("?level")\s?:\s?("(.+?)"|\d|null)->$1: "20t"&("?name")\s?:\s?("(.+?)"|\d|null)->$1: "20T超级会员"
云盘描述 = type=http-response,pattern=https:\/\/api\.aliyundrive\.com\/business\/v1\/users\/me\/vip\/info, requires-body=1,script-path=https://raw.githubusercontent.com/githubdulong/Script/master/mock.js, argument=("?description")\s?:\s?("(.+?)"|\d|null)->$1: "有效期至 2099-03-20"&("?rightButtonText")\s?:\s?("(.+?)"|\d|null)->$1: "SVIP"&("?level")\s?:\s?("(.+?)"|\d|null)->$1: "20t"

[MITM]
hostname = %APPEND% api.aliyundrive.com
