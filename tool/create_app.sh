#!/usr/bin/env bash
# 兼容入口：等价于 tool/app.sh create ...，保留旧用法。
#
# 用法：tool/create_app.sh <app_name> <org> [display_name] [options]
# 详细选项见：tool/app.sh --help

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/app.sh" create "$@"
