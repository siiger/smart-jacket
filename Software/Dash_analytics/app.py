from jupyter_dash import JupyterDash
from dash import dcc
from dash import html
import dash_bootstrap_components as dbc
from plotly.subplots import make_subplots
import plotly.graph_objs as go
import pandas as pd
import numpy as np
from dash.dependencies import Output, Input
from app_functools import calculate_freq, calculate_irreg, calculate_divide, data_peaks

from tslearn.clustering import KShape
from tslearn.preprocessing import TimeSeriesScalerMeanVariance

from db_postgres import get_data, get_activity


#Get data from database
st = get_data()
act = get_activity()
# calulation data
st['timestamp'] = pd.to_datetime(st.timestamp)
act['timestamp'] = pd.to_datetime(act.timestamp)

activty, che_value, sto_value, che_peaks, sto_peaks, che_freq, sto_freq, che_irreg, sto_irreg, ch_st_div = 'Activity', 'chest', 'stom', 'Che.Peaks', 'Sto.Peaks', 'Che.Freq', 'Sto.Freq', 'Che.Irreg', 'Sto.Irreg', 'Che.Val/Sto.Val' 

a_fch = calculate_freq(st[che_value], st['timestamp'])
a_irrch = calculate_irreg(st[che_value], st['timestamp'])
a_fst = calculate_freq(st[sto_value], st['timestamp'])
a_irrst = calculate_irreg(st[sto_value], st['timestamp'])
a_div = calculate_divide(st[che_value], st[sto_value])
a_pch = data_peaks(st[che_value], st['timestamp'])
a_pst = data_peaks(st[sto_value], st['timestamp'])

st_freq_ch = pd.DataFrame({'timestamp':a_fch[0], che_freq: a_fch[1]})
st_freq_st = pd.DataFrame({'timestamp':a_fst[0], sto_freq: a_fst[1]})
st_irr_ch = pd.DataFrame({'timestamp':a_irrch[0], che_irreg: a_irrch[1]})
st_irr_st = pd.DataFrame({'timestamp':a_irrst[0], sto_irreg: a_irrst[1]})
st_pik_ch = pd.DataFrame({'timestamp':a_pch[0], che_peaks: a_pch[1]})
st_pik_st = pd.DataFrame({'timestamp':a_pst[0], sto_peaks: a_pst[1]})
st_div = pd.DataFrame({'timestamp':st['timestamp'], ch_st_div: a_div})
#


corporate_colors = {
    'dark-blue' : 'rgb(13, 9, 114)',
    'medium-blue' : 'rgb(54, 48, 232)',
    'light-blue' : 'rgb(167, 124, 252)',
    'dark-green' : 'rgb(9, 110, 5)',
    'medium-green' : 'rgb(48, 172, 44)',
    'light-green' : 'rgb(22, 145, 120)',
    'pink-red' : 'rgb(255, 101, 131)',
    'dark-pink-red' : 'rgb(247, 80, 99)',
    'white' : 'rgb(251, 251, 252)',
    'light-grey' : 'rgb(208, 206, 206)',
    'brown': 'rgb(229, 151, 50)',
    'axis-grey': '#e2e2e2',
    'font-grey': '#606060',
    'bg-white': '#f9f9f9',
    'sto-value-blue' : '#3a97e9',
    'che-value-green' : '#43b582',
    'bar-orange' : '#f5cf8b',
}

# id 
id_sliders = ['slider1', 'slider2']
id_dropds = ['drop1', 'drop2']

# dropdown options 1
features = [activty, che_value, sto_value, che_peaks, sto_peaks, che_freq, sto_freq, che_irreg, sto_irreg, ch_st_div]
opts1 = [{'label' : i, 'value' : i} for i in features]
#

# dropdown options 2
features2 = [che_value, sto_value]
opts2 = [{'label' : i, 'value' : i} for i in features2]
init_opts2 = [sto_value]
#

# range slider options
std = st['timestamp'][2:].tolist()
c = len(std)
count_marks = int(float(c)//180)

j=0
dates = []
for j in range(count_marks):
    dates.append(std[j*180])
if int(c%180)!=0:
    dates.append(std[c-1])
    count_marks+=1 


count_dot = 10         
len_marks1 = int(float(count_marks)//count_dot)
Times = {}
j=0
for j in range(count_dot):
    Times.update({int(j*len_marks1): dates[j*len_marks1].strftime("%B %d %H:%M")})   
if int(count_marks%len_marks1)!=0:
    Times.update({int(count_marks-1): dates[count_marks-1].strftime("%B %d %H:%M")})   
    #count_marks+=1      
# 

# Create a plotly figure for data
g_opt1, g_opt2 = [opts1[0]["value"], opts1[1]["value"], opts1[2]["value"]],      [opts1[5]["value"], opts1[6]["value"]]
init_opts1 = [g_opt1[0],g_opt1[1], g_opt1[2], g_opt2[0], g_opt2[1]]
fig = make_subplots(rows=2, cols=1)
fig.append_trace(go.Scatter(x = st.timestamp, y = st[che_value],name = che_value,line = dict(width = 2,color = corporate_colors['che-value-green'])),1,1)
fig.append_trace(go.Scatter(x = st.timestamp, y = st[sto_value],name = sto_value,line = dict(width = 2,color = corporate_colors['sto-value-blue'])),1,1)
fig.append_trace(go.Scatter(x = st_freq_ch.timestamp, y = st_freq_ch[che_freq],name = che_freq,line = dict(width = 2,color = corporate_colors['medium-green'])),2,1)
fig.append_trace(go.Scatter(x = st_freq_st.timestamp, y = st_freq_st[sto_freq],name = sto_freq,line = dict(width = 2,color = corporate_colors['medium-blue'])),2,1)
fig.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
fig.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
fig.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])



# ML clustering
dt = 10
data0 = st[sto_value].tolist()
lo = len(data0)//dt
#print(lo)
data0 = data0[:lo*dt]
DTIME = st['timestamp'].tolist()
data1 = np.reshape(data0, (lo, dt))
#print(data1.shape)
X = data1
t = np.arange(dt)
n_clus = 3
cluster_titl = ["Cluster %d" % (i + 1) for i in np.arange(n_clus)]
h = np.zeros(n_clus)
X = TimeSeriesScalerMeanVariance(mu=0., std=0.5).fit_transform(X)
ks = KShape(n_clusters=n_clus, n_init=1, random_state=0).fit(X)
ks.cluster_centers_.shape
y_pred = ks.fit_predict(X)

figCl = make_subplots(rows=n_clus, cols=1, subplot_titles=(cluster_titl))
for yi in range(n_clus):
    for xx in X[y_pred == yi]:
        h[yi] = h[yi]+1
        figCl.append_trace(go.Scatter(
            x=t,
            y=xx.ravel(),
            line=dict(width=2,
                      color=corporate_colors['bar-orange']),
        ), row=yi+1, col=1),
    figCl.append_trace(go.Scatter(
        x=t,
        y=ks.cluster_centers_[yi].ravel(),
        line=dict(width=2,
                  color='rgb(0, 151, 50)')
    ), row=yi+1, col=1)
figCl.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
figCl.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
figCl.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])
figBar = go.Figure([go.Bar(x=cluster_titl, y=h, marker={'color': corporate_colors['bar-orange']})])
figBar.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
figBar.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
figBar.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])



#####_____________APP________________####
#########################################
app = JupyterDash(external_stylesheets=[dbc.themes.SANDSTONE])
server = app.server
app.title = "Breathing Analytics: Understand Your Breathing!"

def drawSlider(id_slider, title):
    return  html.Div([
                html.Div(
                    children= title, className="slider-title"
                ),
                html.Div(
                    children=[
                            dcc.RangeSlider(id = id_slider,
                                        min = 0,
                                        max = count_marks-1,
                                        value = [0, count_marks-1],
                                        marks={
                                            str(pos): {
                                                "label": str(Times.get(pos)),
                                                "style": {"color": "#9b9b9b", "width": "9%"},
                                            }
                                            for pos in Times.keys()
                                        },
                            ),
                    ],
                    className="wrapper-slider", 
                ),
                    ],
                )
  

def drawDropdown(opts, init_opts, id_dropd):
    return   html.Div(
                children=[
                    html.Div(children="Features", className="menu-title"),
                    html.Div(
                            children=[dcc.Dropdown(id = id_dropd, options = opts,
                                value = init_opts, multi=True, style = {'width': '96%'})
                            ],
                            className="wrapper-options",  
                    ),
                    ],  
                )
   
def drawMenu(opts, init_opts, id_dropd, id_slider):
    return html.Div([
        dbc.Card([ 
            dbc.CardBody([
                drawSlider(id_slider, "Date Range"),
                drawDropdown(opts, init_opts, id_dropd), 
            ],)
        ],
        className="menu",
        ),
    ])
def drawDataFigure():
    return html.Div([
        dbc.Card([ 
            dbc.CardBody([
               dcc.Graph(id = 'plot', figure = fig),
                
            ],)
        ],
        className="wrapper-card",
        ),
    ]) 

def drawClusteringMenu(opts, init_opts, id_dropd, id_slider):
    return html.Div([
        dbc.Card([ 
            dbc.CardBody([
                    drawSlider(id_slider, "Date Range for Clustering"),
                    dbc.Row([
                         dbc.Col([
                         drawDropdown(opts, init_opts, id_dropd),
                         ], width=8),
                         dbc.Col([
                         html.Div(
                            children=[
                                html.Div(children="Cluster count", className="menu-title-input"),
                                html.Div(children=[dcc.Input(id="cluster-count", type="number", value=2),],
                                   className="wrapper-input",  
                                  ),
                                ],  
                            ),    
                         ], width=3),
                        ]),
                     ],)
                ],
             className="menu",
             ),
    ])

def drawClusterFigure():
    return html.Div([
        dbc.Card([ 
            dbc.CardBody([
               dcc.Graph(id='plotCl', figure=figCl),   
            ],)
        ],
        className="wrapper-card1",
        ),
    ]) 

def drawBarFigure():
    return html.Div([
        dbc.Card([ 
            dbc.CardBody([
               dcc.Graph(id='plotBar', figure=figBar),
            ],)
        ],
        className="wrapper-card1",
        ),
    ])       

def drawText():
    return html.Div(
        children=[
                #html.P(children="health-graph.ico", className="header-emoji"),
                html.H1(
                    children="Breathing Analytics", className="header-title"
                ),
                html.P(
                    children="Data analysis of breathing characteristics",
                    className="header-description",
                ),
                ], className="header"
                )

app.layout = html.Div(
    children=[
        dbc.Card(
            dbc.CardBody([
                dbc.Row([
                    dbc.Col([
                    drawText(),
                    ]),
                ], align='center'),    
                dbc.Row([
                    dbc.Col([
                    drawMenu(opts1, init_opts1, id_dropds[0], id_sliders[0]),
                    ]),
                ], align='center'),
                html.Br(),
                dbc.Row([
                    dbc.Col([
                    drawDataFigure(),
                    ]),
                ], align='center'),
                html.Br(),       
                dbc.Row([
                    dbc.Col([
                    drawClusteringMenu(opts2, init_opts2, id_dropds[1], id_sliders[1]),
                    ]),
                ], align='center'),       
                dbc.Row([
                    dbc.Col([
                    drawClusterFigure()
                    ], width=6),
                    dbc.Col([
                    drawBarFigure()
                    ], width=6),
                    ], align='center'),                  
            ],className="basic"
            ),
        ),]
)


# Add callback functions
@app.callback(
                 Output('plot', 'figure'),
             [
                 Input(id_dropds[0], 'value'),
                 Input(id_sliders[0], 'value')
             ])
def update_figure(input1, input2):
    # updating the plot
    trace1, trace2, act1 = [], [], []
    for optt in input1:
        if optt in g_opt1:
           st1 = st[(st.timestamp >= dates[input2[0]]) & (st.timestamp <= dates[input2[1]])]
           if optt == che_value: 
              trace1.append(go.Scatter(x = st1.timestamp, y = st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['che-value-green'])))
           if optt == sto_value: 
              trace1.append(go.Scatter(x = st1.timestamp, y = st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['sto-value-blue']))) 
        if optt == che_peaks:
           st_pik_ch1 = st_pik_ch[(st_pik_ch.timestamp >= dates[input2[0]]) & (st_pik_ch.timestamp <= dates[input2[1]])] 
           trace1.append(go.Scatter(x = st_pik_ch1.timestamp, y = st_pik_ch1[optt],name = optt,mode='markers',marker=dict(size=6,color = corporate_colors['light-green'],symbol='cross'),))
        if optt == sto_peaks:
           st_pik_st1 = st_pik_st[(st_pik_st.timestamp >= dates[input2[0]]) & (st_pik_st.timestamp <= dates[input2[1]])] 
           trace1.append(go.Scatter(x = st_pik_st1.timestamp, y = st_pik_st1[optt],name = optt,mode='markers',marker=dict(size=6,color = corporate_colors['light-blue'],symbol='cross'),))        
        if optt == che_freq:
           st_freq_ch1 = st_freq_ch[(st_freq_ch.timestamp >= dates[input2[0]]) & (st_freq_ch.timestamp <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_freq_ch1.timestamp, y = st_freq_ch1[optt],name = optt,line = dict(width = 2,color = corporate_colors['medium-green'])))
        if optt == sto_freq:
           st_freq_st1 = st_freq_st[(st_freq_st.timestamp >= dates[input2[0]]) & (st_freq_st.timestamp <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_freq_st1.timestamp, y = st_freq_st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['medium-blue'])))
        if optt == che_irreg:
           st_irr_ch1 = st_irr_ch[(st_irr_ch.timestamp >= dates[input2[0]]) & (st_irr_ch.timestamp <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_irr_ch1.timestamp, y = st_irr_ch1[optt],name = optt,line = dict(width = 2,color = corporate_colors['light-green'])))
        if optt == sto_irreg:
           st_irr_st1 = st_irr_st[(st_irr_st.timestamp >= dates[input2[0]]) & (st_irr_st.timestamp <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_irr_st1.timestamp, y = st_irr_st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['light-blue'])))
        if optt == ch_st_div:
           st_div1 = st_div[(st_div.timestamp >= dates[input2[0]]) & (st_div.timestamp <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_div1.timestamp, y = st_div1[optt],name = optt,line = dict(width = 2,color = corporate_colors['brown'])))          
    
    data1 = [val for sublist in [trace1] for val in sublist]
    data2 = [val for sublist in [trace2] for val in sublist]
    
    fig = make_subplots(rows=2, cols=1)
    for tr in data1:
        fig.append_trace(tr,1,1,)
    for tr in data2:
        fig.append_trace(tr,2,1)

    for optt in input1:
        if optt == activty:
            fig.update_layout(margin=dict(l=50, r=0,))
            act1 = act[(act.timestamp > dates[input2[0]]) & (act.timestamp < dates[input2[1]])]      
            array1 = act1.timestamp.tolist()
            array1.append(dates[input2[1]])
            array2 = act1.act.tolist()
            act_l = act[(act.timestamp < dates[input2[0]])]
            array_l = act_l.timestamp.tolist()
            if len(array_l)!=0:
                array2.insert(0, act_l.act.tolist()[-1])
                array1.insert(0, dates[input2[0]])
                  
                      
            len1 =len(array1)
            for i in range(len1 - 1):
                #arrayy1.append(1350 ) 
                fig.add_shape(type="rect", x0=array1[i], x1=array1[i+1], y0= 1300, y1=1900, line_width=1.5)
                fig.add_annotation(x=array1[i], y=1350, text=array2[i], showarrow=False, align="right", xanchor='left', xref="x", yref="y")
            #fig.add_trace(go.Scatter(x=array1, y=arrayy1, text=array2, mode="text", textposition="top right"), 1,1) 

    fig.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    fig.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    fig.update_layout( font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])
    return fig




# Add callback functions for Clastering data
@app.callback([
                Output('plotCl', 'figure'),
                Output('plotBar', 'figure'),
              ],   
              [
                 Input(id_dropds[1], 'value'),
                 Input(id_sliders[1], 'value'),
                 Input("cluster-count", "value"),
              ])
def update_figure(input1, input2, input3):
    # updating the plot
    data0, DTIME= [], []
    for optt in input1:
           st1 = st[(st.timestamp >= dates[input2[0]]) & (st.timestamp <= dates[input2[1]])]
           data0 = st1[optt].tolist()
           DTIME = st1.timestamp.tolist()          
    
    
    # ML clustering
    dt = 10
    lo = len(data0)//dt
    #print(lo)
    data0 = data0[:lo*dt]
    data1 = np.reshape(data0, (lo, dt))
    #print(data1.shape)
    X = data1
    t = np.arange(dt)
    n_clus = input3
    cluster_titl = ["Cluster %d" % (i + 1) for i in np.arange(n_clus)]
    h = np.zeros(n_clus)
    X = TimeSeriesScalerMeanVariance(mu=0., std=0.5).fit_transform(X)
    ks = KShape(n_clusters=n_clus, n_init=1, random_state=0).fit(X)
    ks.cluster_centers_.shape
    y_pred = ks.fit_predict(X)

    figCl = make_subplots(rows=n_clus, cols=1, subplot_titles=(cluster_titl))
    for yi in range(n_clus):
        for xx in X[y_pred == yi]:
            h[yi] = h[yi]+1
            figCl.append_trace(go.Scatter(
                x=t,
                y=xx.ravel(),
                line=dict(width=2,
                        color=corporate_colors['bar-orange']),
            ), row=yi+1, col=1),
        figCl.append_trace(go.Scatter(
            x=t,
            y=ks.cluster_centers_[yi].ravel(),
            line=dict(width=2,
                    color='rgb(0, 151, 50)')
        ), row=yi+1, col=1)
    figBar = go.Figure([go.Bar(x=cluster_titl, y=h, marker={'color': corporate_colors['bar-orange']})])
    figCl.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])
    figCl.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    figCl.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    figBar.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    figBar.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    figBar.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])    
    return figCl , figBar


if __name__ == "__main__":
   app.run_server(debug=True)
