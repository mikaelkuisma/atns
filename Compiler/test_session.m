atn = session('mysession');
atn.source('producer.model');
atn.add(yearly_plot());
atn.run('myrun');
