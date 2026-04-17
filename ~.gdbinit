set breakpoint pending on
set disassembly-flavor intel
set print pretty on
python
import sys
# Path may vary; common paths include /usr/share/gcc/python or similar
sys.path.insert(0, '/usr/share/gcc/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
end
