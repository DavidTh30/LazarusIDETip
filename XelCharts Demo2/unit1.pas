unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  XelChartTypes, XelLineChart, XelBarChart, XelPieChart, XelSparkline;

type

  { TForm1 }

  TForm1 = class(TForm)
    Timer1: TTimer;
    XelLineChart1: TXelLineChart;
    XelSparkline1: TXelSparkline;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  Revenue : array of Double;
  Cost    : array of Double;
  Support : array of Double;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
const Months : array[0..11] of String =
  ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

var
  i: Integer;
  C: TXelLineChart;
  Sp: TXelSparkline;

begin
  SetLength(Revenue, 12);
  SetLength(Cost, 12);
  SetLength(Support, 12);

  Revenue :=
    [412, 388, 455, 501, 478, 533, 590, 612, 587, 640, 705, 748];
  Cost    :=
    [301, 295, 322, 340, 351, 366, 388, 401, 396, 410, 447, 470];
  Support :=
    [ 61,  58,  70,  66,  74,  81,  77,  90,  84,  95, 101,  98];

  //Line chart
  C := XelLineChart1;
  C.Theme  := ctLight;
  C.Title  := 'Monthly revenue and cost';
  C.Footer := 'thousands of EUR';

  for i := 0 to 11 do C.Categories.Add(Months[i]);
  C.AddSeries('Revenue', Revenue).Style := ssLine;
  C.AddSeries('Cost', Cost).Style := ssLine;
  C.AddSeries('Support', Support).Style := ssLine;
  C.AxisY.LabelFormat := '%.0f';
  C.AxisX.TickCount   := 12;
  C.MarkLast := True;

  //Spark line
  Sp := XelSparkline1;
  Sp.SetData(Revenue);

  timer1.Enabled:=true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  v:double;
  s:string;
begin
  Randomize;

  Delete(Revenue, 0, 1);
  SetLength(Revenue, 12);
  v:=Revenue[5]+Revenue[6]+Revenue[7]+Revenue[8]+Revenue[9]+Revenue[10]+Random(801);
  s:=FormatFloat('0.00', v/7);
  v:=s.ToDouble;
  Revenue[11]:=v;

  //XelLineChart1.Series[0].Delete(0);
  XelLineChart1.Series[0].SetData(Revenue);
  ////XelLineChart1.Series[0].Add(Revenue[11]);


end;

end.

