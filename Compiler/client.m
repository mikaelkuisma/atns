t = tcpip('localhost', 8000, 'NetworkRole', 'client');
fopen(t)
t.write('Moro');
t.read()