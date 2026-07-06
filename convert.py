#!/usr/bin/env python3
#
import os
from pathlib import Path

dir_cwd = Path(os.getcwd()) / "src"

file_list_delete = (
    "nvim/po/af.po",
    "nvim/po/cs.po",
    "nvim/po/fi.po",
    "nvim/po/ja.po",
    "nvim/po/pt_BR.po",
    "nvim/po/ca.po",
    "nvim/po/da.po",
    "nvim/po/ko.UTF-8.po",
    "nvim/po/ru.po",
    "nvim/po/tr.po",
    "nvim/po/fr.po",
    "nvim/po/nb.po",
    "nvim/po/sk.cp1250.po",
    "nvim/po/uk.po",
    "nvim/po/en_GB.po",
    "nvim/po/ga.po",
    "nvim/po/nl.po",
    "nvim/po/sk.po",
    "nvim/po/vi.po",
    "nvim/po/eo.po",
    "nvim/po/it.po",
    "nvim/po/no.po",
    "nvim/po/sr.po",
    "nvim/po/zh_CN.UTF-8.po",
    "nvim/po/cs.cp1250.po",
    "nvim/po/es.po",
    "nvim/po/ja.euc-jp.po",
    "nvim/po/pl.UTF-8.po",
    "nvim/po/sv.po",
    "nvim/po/zh_TW.UTF-8.po",
)


if __name__ == "__main__":
    print(dir_cwd)
    for f in file_list_delete:
      fn = dir_cwd / f
      fn.unlink()
