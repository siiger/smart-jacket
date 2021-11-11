import dash
from dash import dcc
from dash import html
from plotly.subplots import make_subplots
import plotly.graph_objs as go
import pandas as pd
import numpy as np
from dash.dependencies import Output, Input
from app_functools import calculate_freq, calculate_irreg, calculate_divide, data_peaks


# Import the dataset
filepath_st = '/data/sensordata.csv'
st = pd.read_csv(filepath_st)

filepath_actv = '/data/sensordataactivity.csv'
act = pd.read_csv(filepath_actv)
#
# calulation data
st['Date'] = pd.to_datetime(st.Date)
act['Date'] = pd.to_datetime(act.Date)

activty, che_value, sto_value, che_peaks, sto_peaks, che_freq, sto_freq, che_irreg, sto_irreg, ch_st_div = 'Activity', 'Che.Value', 'Sto.Value', 'Che.Peaks', 'Sto.Peaks', 'Che.Freq', 'Sto.Freq', 'Che.Irreg', 'Sto.Irreg', 'Che.Val/Sto.Val' 

a_fch = calculate_freq(st[che_value], st['Date'])
a_irrch = calculate_irreg(st[che_value], st['Date'])
a_fst = calculate_freq(st[sto_value], st['Date'])
a_irrst = calculate_irreg(st[sto_value], st['Date'])
a_div = calculate_divide(st[che_value], st[sto_value])
a_pch = data_peaks(st[che_value], st['Date'])
a_pst = data_peaks(st[sto_value], st['Date'])

st_freq_ch = pd.DataFrame({'Date':a_fch[0], che_freq: a_fch[1]})
st_freq_st = pd.DataFrame({'Date':a_fst[0], sto_freq: a_fst[1]})
st_irr_ch = pd.DataFrame({'Date':a_irrch[0], che_irreg: a_irrch[1]})
st_irr_st = pd.DataFrame({'Date':a_irrst[0], sto_irreg: a_irrst[1]})
st_pik_ch = pd.DataFrame({'Date':a_pch[0], che_peaks: a_pch[1]})
st_pik_st = pd.DataFrame({'Date':a_pst[0], sto_peaks: a_pst[1]})
st_div = pd.DataFrame({'Date':st['Date'], ch_st_div: a_div})
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
}

# dropdown options
features = [activty, che_value, sto_value, che_peaks, sto_peaks, che_freq, sto_freq, che_irreg, sto_irreg, ch_st_div]
opts = [{'label' : i, 'value' : i} for i in features]
#

# range slider options
std = st['Date'][2:].tolist()
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
g_opt1, g_opt2 = [opts[0]["value"], opts[1]["value"], opts[2]["value"]],      [opts[5]["value"], opts[6]["value"]]
init_opts = [g_opt1[0],g_opt1[1], g_opt1[2], g_opt2[0], g_opt2[1]]
fig = make_subplots(rows=2, cols=1)
fig.append_trace(go.Scatter(x = st.Date, y = st[che_value],name = che_value,line = dict(width = 2,color = corporate_colors['che-value-green'])),1,1)
fig.append_trace(go.Scatter(x = st.Date, y = st[sto_value],name = sto_value,line = dict(width = 2,color = corporate_colors['sto-value-blue'])),1,1)
fig.append_trace(go.Scatter(x = st_freq_ch.Date, y = st_freq_ch[che_freq],name = che_freq,line = dict(width = 2,color = corporate_colors['medium-green'])),2,1)
fig.append_trace(go.Scatter(x = st_freq_st.Date, y = st_freq_st[sto_freq],name = sto_freq,line = dict(width = 2,color = corporate_colors['medium-blue'])),2,1)
fig.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
fig.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
fig.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])


external_stylesheets = [
    {
        "href": "https://fonts.googleapis.com/css2?"
        "family=Lato:wght@400;700&display=swap",
        "rel": "stylesheet",
    },
]
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
server = app.server
app.title = "Breathing Analytics: Understand Your Breathing!"

app.layout = html.Div(
    children=[
        html.Div(
            children=[
                #html.P(children="health-graph.ico", className="header-emoji"),
                html.H1(
                    children="Breathing Analytics", className="header-title"
                ),
                html.P(
                    children="Data analysis of breathing characteristics",
                    className="header-description",
                ),
            ],
            className="header",
        ),
        html.Div(
            children=[
                html.Div(
                    children=[
                        html.Div(
                            children="Date Range", className="slider-title"
                        ),
                        html.Div(
                            children=[
                                    dcc.RangeSlider(id = 'slider',
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
                ),

                html.Div(
                    children=[
                        html.Div(children="Features", className="menu-title"),
                        html.Div(
                                children=[dcc.Dropdown(id = 'opt', options = opts,
                                    value = init_opts, multi=True, style = {'width': '96%'})
                                ],
                                className="wrapper-options",  
                        ),
                    ],  
                ),                                             
                
            ],
            className="menu",
        ),
        html.Div(
            children=[
                html.Div(
                    children=[dcc.Graph(id = 'plot', figure = fig),],
                    className="card",
                ),
            ],
            className="wrapper-card",
        ),
    ]
)


# Add callback functions
@app.callback(Output('plot', 'figure'),
             [Input('opt', 'value'),
             Input('slider', 'value')])
def update_figure(input1, input2):
    # updating the plot
    trace1, trace2, act1 = [], [], []
    for optt in input1:
        if optt in g_opt1:
           st1 = st[(st.Date >= dates[input2[0]]) & (st.Date <= dates[input2[1]])]
           if optt == che_value: 
              trace1.append(go.Scatter(x = st1.Date, y = st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['che-value-green'])))
           if optt == sto_value: 
              trace1.append(go.Scatter(x = st1.Date, y = st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['sto-value-blue']))) 
        if optt == che_peaks:
           st_pik_ch1 = st_pik_ch[(st_pik_ch.Date >= dates[input2[0]]) & (st_pik_ch.Date <= dates[input2[1]])] 
           trace1.append(go.Scatter(x = st_pik_ch1.Date, y = st_pik_ch1[optt],name = optt,mode='markers',marker=dict(size=6,color = corporate_colors['light-green'],symbol='cross'),))
        if optt == sto_peaks:
           st_pik_st1 = st_pik_st[(st_pik_st.Date >= dates[input2[0]]) & (st_pik_st.Date <= dates[input2[1]])] 
           trace1.append(go.Scatter(x = st_pik_st1.Date, y = st_pik_st1[optt],name = optt,mode='markers',marker=dict(size=6,color = corporate_colors['light-blue'],symbol='cross'),))        
        if optt == che_freq:
           st_freq_ch1 = st_freq_ch[(st_freq_ch.Date >= dates[input2[0]]) & (st_freq_ch.Date <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_freq_ch1.Date, y = st_freq_ch1[optt],name = optt,line = dict(width = 2,color = corporate_colors['medium-green'])))
        if optt == sto_freq:
           st_freq_st1 = st_freq_st[(st_freq_st.Date >= dates[input2[0]]) & (st_freq_st.Date <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_freq_st1.Date, y = st_freq_st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['medium-blue'])))
        if optt == che_irreg:
           st_irr_ch1 = st_irr_ch[(st_irr_ch.Date >= dates[input2[0]]) & (st_irr_ch.Date <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_irr_ch1.Date, y = st_irr_ch1[optt],name = optt,line = dict(width = 2,color = corporate_colors['light-green'])))
        if optt == sto_irreg:
           st_irr_st1 = st_irr_st[(st_irr_st.Date >= dates[input2[0]]) & (st_irr_st.Date <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_irr_st1.Date, y = st_irr_st1[optt],name = optt,line = dict(width = 2,color = corporate_colors['light-blue'])))
        if optt == ch_st_div:
           st_div1 = st_div[(st_div.Date >= dates[input2[0]]) & (st_div.Date <= dates[input2[1]])] 
           trace2.append(go.Scatter(x = st_div1.Date, y = st_div1[optt],name = optt,line = dict(width = 2,color = corporate_colors['brown'])))          
    
    data1 = [val for sublist in [trace1] for val in sublist]
    data2 = [val for sublist in [trace2] for val in sublist]
    fig = make_subplots(rows=2, cols=1)
    for tr in data1:
        fig.append_trace(tr,1,1,)
    for tr in data2:
        fig.append_trace(tr,2,1)

    for optt in input1:
        if optt == activty:
            act1 = act[(act.Date > dates[input2[0]]) & (act.Date < dates[input2[1]])]      
            array1 = act1.Date.tolist()
            array1.append(dates[input2[1]]) 
            array2 = act1.Activity.tolist()
            
            act_l = act[(act.Date < dates[input2[0]])]
            array_l = act_l.Date.tolist()
            if len(array_l)!=0:
                array2.insert(0, act_l.Activity.tolist()[-1])
                array1.insert(0, dates[input2[0]])  
                      
            len1 =len(array1)
            for i in range(len1 - 1):
                fig.add_vrect(x0=array1[i], x1=array1[i+1], annotation_text=array2[i], annotation_position="bottom left", line_width=0.5)
    fig.update_xaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    fig.update_yaxes(showline=True, linewidth=2, linecolor=corporate_colors['axis-grey'], gridcolor=corporate_colors['axis-grey'])
    fig.update_layout(font_color=corporate_colors['font-grey'], plot_bgcolor = corporate_colors['bg-white'], paper_bgcolor = corporate_colors['bg-white'])
    return fig



if __name__ == "__main__":
    app.run_server(debug=False)
