proc import datafile='/home/u63491031/KIGEA/train.csv'
    dbms=csv
    out=train
    replace;
    getnames=yes;
run;


data train1;
  set train;
  adj_date = intnx('month', Date, 0, 'beginning');
run;


proc univariate data=train1 noprint;
  by Store Dept adj_date IsHoliday;
  var Weekly_Sales;
  output out=SummarySales(drop=_type_ _freq_) 
         mean=MeanSales std=StdDevSales min=MinSales max=MaxSales nmiss=NMissing;
run;

data SummarySalesRefined;
  set SummarySales;
  where not missing(StdDevSales);
  StdDevSales = coalesce(StdDevSales, -1); /* Replace missing values with -1 or any other appropriate value */
run;

/* Display the results in SAS */
proc print data=SummarySalesRefined;
  title 'Summary of Sales over the Holiday per Store/Department for Each Month';
  format adj_date MONYY.;
run;


ods graphics on;

proc sgplot data=SummarySalesRefined;
  title 'Mean Sales Over Holiday per Store/Department for Each Month';
  format adj_date MONYY.;
  series x=adj_date y=MeanSales / group=IsHoliday;
  xaxis label='Month';
  yaxis label='Mean Sales';
run;


proc sgplot data=SummarySalesRefined;
  title 'Standard Deviation Over Holiday per Store/Department for Each Month';
  format adj_date MONYY.;
  series x=adj_date y=StdDevSales / group=IsHoliday;
  xaxis label='Month';
  yaxis label='Standard Deviation Sales';
run;


proc sgplot data=SummarySalesRefined;
  title 'Min and Max Range Over Holiday per Store/Department for Each Month';
  format adj_date MONYY.;
  series x=adj_date y=MinSales / group=IsHoliday;
  series x=adj_date y=MaxSales / group=IsHoliday;
  xaxis label='Month';
  yaxis label='Sales Range';
run;


ods graphics off;
