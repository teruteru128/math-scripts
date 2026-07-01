# https://share.google/aimode/EAw62BtCMh6tWsKOq
# grep -E "certs/[[:digit:]]+-cert[[:digit:]]+\.txt\"," tests/gp-tests.gp | head -n 10 | sed -r -e 's|write\(\"certs/([[:digit:]]+-cert[[:digit:]]+)\.txt\", primecertexport|(primecert\(([[:digit:]]+)\), 1\)\)/mpirun -np 4 ecpp-mpi -g -t -c -f \1 -n \2|g' > 3281-cert3166.sh
grep "certs/" tests/gp-tests.gp | sed -r -e 's|write\("certs/([^.]+)\.txt", primecertexport\(primecert\(([^)]+)\), 1\)\)|mpirun -np 4 ecpp-mpi -g -t -c -f \1 -n \2|g' > certs_tasks.sh

