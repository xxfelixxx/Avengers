// meta title=Top 5 Sites - Auto Manufactures
// meta package=corechart
// meta width=100%
// meta source=Hitwise
function drawVisualization() {
    // Some raw data (not necessarily accurate)
    var data = google.visualization.arrayToDataTable([
        ['Month',   'Ford Motor Company', 'Chevrolet', 'GMC', "O'Reilly Auto Parts", 'Toyota Motor Sales'],

        ['2012/01/8',8.016568173,5.366590582,4.559560437,4.797794561,3.479206275],
        ['2012/01/15',7.197570048,5.425359483,4.614237483,4.792635017,3.523678628],
        ['2012/01/22',7.64300216,5.489885697,4.558995435,4.699015912,3.482976923],
        ['2012/01/29',6.834497493,5.597545901,4.664566662,4.667804462,3.605500971],
        ['2012/02/5',6.610931199,5.601823947,4.674992082,4.657762,3.694855169],
        ['2012/02/12',6.435918814,5.594416505,4.719432396,4.580586962,3.570278155],
        ['2012/02/19',5.995168119,5.670497525,4.71262523,4.527950466,3.582603789],
        ['2012/02/26',5.219482452,5.772515049,4.739055613,4.415042765,3.529254172],
        ['2012/03/4',6.179894237,5.709040447,4.790724761,4.374169239,3.42288371],
        ['2012/03/11',6.262275037,5.80452534,4.69074515,4.328736393,3.459702711],
        ['2012/03/18',6.270479562,5.738459149,4.689379975,4.444729056,3.579083905],
        ['2012/03/25',6.568491779,5.82519763,4.769585591,4.372808723,3.616249552],
        ['2012/04/1',6.312714485,5.791747994,4.786575988,4.325020372,3.701051346],
        ['2012/04/8',5.933840478,5.718521309,4.730724453,4.315066477,3.824990531],
        ['2012/04/15',5.819042384,5.696992685,4.635088525,4.30984792,3.910871539],
        ['2012/04/22',5.361383932,5.663739075,4.635340757,4.362197966,3.840353665],
        ['2012/04/29',5.461530422,5.688340752,4.694675173,4.272065387,3.954484596],
        ['2012/05/6',5.238252992,5.759999996,4.574323051,4.234835369,3.939891866],
        ['2012/05/13',6.0711721,5.701305281,4.459216927,4.192441327,4.000718657],
        ['2012/05/20',6.820327908,5.657308123,4.522838894,4.262126427,4.053127844],
        ['2012/05/27',6.86,5.64,4.62,4.25,4.04],
    ]);

  // Create and draw the visualization.
    var ac = new google.visualization.AreaChart(document.getElementById('visualization'));
    ac.draw(data, {
        title : 'Top 5 Websites : Automotive > Manufacturers',
        isStacked: true,
        width: 400,
        height: 250,
        vAxis: {title: "Percent of Internet Traffic"},
    });
}