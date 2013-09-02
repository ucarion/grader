jQuery ->
  $('.datepicker').datepicker()

  chart = $('#analytics-chart')
  if chart.length != 0
    chart.highcharts({
      chart:
        type: 'column'
      ,
      title:
        text: 'Class Average Score by Assignment'
      ,
      xAxis:
        categories: assignment_names
      ,
      yAxis:
        min: 0
        title:
          text: 'Score (%)'
      ,
      tooltip:
        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + 
          '<td style="padding:0"><b>{point.y:.1f} %</b></td></tr>'
      series: [{
        name: 'Class Average'
        data: scores
      }]
    })
