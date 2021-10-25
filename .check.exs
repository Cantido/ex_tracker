# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

[
  tools: [
    {:sobelow, "mix sobelow --exit --skip"},
    {:reuse, ["reuse", "lint"]}
  ]
]
