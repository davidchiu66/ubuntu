#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# 校验KOMARI_SERVER环境变量是否非空
if [ -z "$KOMARI_SERVER" ]; then
    echo "错误：环境变量 KOMARI_SERVER 未定义或值为空，请先配置！" >&2
    exit 1
fi

# 校验AGENT_TOKEN环境变量是否非空
if [ -z "$AGENT_TOKEN" ]; then
    echo "错误：环境变量 AGENT_TOKEN 未定义或值为空，请先配置！" >&2
    exit 1
fi

# 双引号包裹变量，防止特殊字符拆分，规范执行命令
./agent -e "$KOMARI_SERVER" -t "$AGENT_TOKEN"
