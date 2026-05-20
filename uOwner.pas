unit uOwner;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  VclTee.TeeGDIPlus, Data.DB, VclTee.TeeData, VclTee.TeEngine, VclTee.Series,
  VclTee.TeeProcs, VclTee.Chart, VclTee.DBChart, Vcl.StdCtrls, Math;

type
  TfrmOwner = class(TForm)
    imgAdministration: TImage;
    lblOwner: TLabel;
    DBChart: TDBChart;
    btnLogout: TButton;
    lblUserLog: TLabel;
    cmbYear: TComboBox;
    gpbChartVariables: TGroupBox;
    btnDrawChart: TButton;
    cmbMonth: TComboBox;
    chkTotal: TCheckBox;
    cmbAuctioneers: TComboBox;
    cmbPropertyType: TComboBox;
    cmbLocation: TComboBox;
    chkOverMonths: TCheckBox;
    Series1: TBarSeries;
    btnHelp: TButton;
    imgHelp: TImage;
    procedure btnLogoutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnDrawChartClick(Sender: TObject);
    procedure cmbAuctioneersChange(Sender: TObject);
    procedure DBChartDblClick(Sender: TObject);
    procedure cmbMonthChange(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    function AllAuctioneers_1Month_Total: string;
    function AllMonths_AllAuctioneer_OverMonths_Totals: string;
    function OverMonths_1Auctioneer_AllMonths: string;
    procedure OverMonths_1Auctioneer_1Month(var sSQL: string);
    function Totals_NOT_OverMonths: string;
    function NoOverMonths_NoTotals: string;
    function AllMonths_AllAuctioneer_OverMonths: string;
    function OverMonths_1Auctioneer_AllMonths_Totals: string;
    { Private declarations }
  public
    { Public declarations }
    procedure LoadAuctioneers;
    procedure LoadYears;
    procedure LoadPropertyType;
    procedure LoadLocations;
    procedure ResetGraph;
    function AuctioneerSQL: String;
    function YearSQL: String;
    function MonthSQL: String;
    function LocationSQL: String;
    function PropertyTypeSQL: String;
  end;

var
  frmOwner: TfrmOwner;

implementation

{$R *.dfm}

uses
  uLogin, Users_u, dmPAT_DB_U;

function TfrmOwner.AuctioneerSQL: String;
begin
  If (cmbAuctioneers.ItemIndex > 0) then
    result := ' AND (tblUsers.Users_Name & " " & tblUsers.Users_Surname) = "' +
      cmbAuctioneers.Items[cmbAuctioneers.ItemIndex] + '"';
end;

procedure TfrmOwner.btnDrawChartClick(Sender: TObject);
var
  sSQL: string;
  sAuctioneerFullName: String;
begin
  If (chkOverMonths.Checked = False) then
  begin
    If chkTotal.Checked = False then
    begin // Totals, NOT Over months
      sSQL := NoOverMonths_NoTotals;
    end
    else
    begin // NOT Over months, NOT totals
      sSQL := Totals_NOT_OverMonths;
    end;
  end
  else
  begin
    If (cmbAuctioneers.ItemIndex <= 0) then
    begin
      IF (cmbMonth.ItemIndex > 0) then
      begin
        // Over months, All auctioneers, 1 month
        Series1.Title := sAuctioneerFullName;
        sSQL := AllAuctioneers_1Month_Total;
      end
      else
      begin
        // Over months, All auctioneers, All month
        Series1.Title := 'Total Earned by All Auctioneers in Each Month';
        If chkTotal.Checked = True then
          sSQL := AllMonths_AllAuctioneer_OverMonths_Totals
        else
          sSQL := AllMonths_AllAuctioneer_OverMonths;

      end;
    end
    else
    begin
      IF (cmbMonth.ItemIndex > 0) then
      begin
        // Over months, 1 auctioneer, 1 month
        Series1.Title := cmbAuctioneers.Items[cmbAuctioneers.ItemIndex] +
          ' Total Sales';
        OverMonths_1Auctioneer_1Month(sSQL);
      end
      else
      begin
        If (chkTotal.Checked = True) then
          sSQL := OverMonths_1Auctioneer_AllMonths_Totals
        else
          sSQL := OverMonths_1Auctioneer_AllMonths;
      end;
    end;
  end;

  dmPAT_DB.runSQLB(sSQL);

  If (dmPAT_DB.qryB.RecordCount > 0) then
  begin
    dmPAT_DB.runSQL(sSQL);;
  end
  else
    Showmessage('Your search failed as no auction matches your search.');
end;

procedure TfrmOwner.btnHelpClick(Sender: TObject);
begin

  If (imgHelp.Visible = True) then
  begin
    DBChart.Show;
    imgHelp.Picture.LoadFromFile('GraphHelp.png');
    gpbChartVariables.Show;
    imgHelp.SendToBack;
    imgHelp.Visible := False;
    btnHelp.Caption := 'Help';
  end
  else
  begin
    DBChart.Hide;
    gpbChartVariables.Hide;
    imgHelp.BringToFront;
    imgHelp.Visible := True;
    btnHelp.Caption := 'Back';
  end;
end;

procedure TfrmOwner.btnLogoutClick(Sender: TObject);
begin
  frmLogin.Logout;
  frmLogin.Show;
  frmOwner.Hide;
end;

procedure TfrmOwner.cmbAuctioneersChange(Sender: TObject);
begin
  If (cmbAuctioneers.ItemIndex > 0) AND (cmbMonth.ItemIndex > 0) then
  begin
    chkTotal.Hide;
    chkTotal.Checked := False;
  end
  else
  begin
    chkTotal.Show;
  end
end;

procedure TfrmOwner.cmbMonthChange(Sender: TObject);
begin
  If (cmbMonth.ItemIndex > 0) then
  begin
    chkOverMonths.Hide;
    chkOverMonths.Checked := False;
  end
  else
  begin
    chkOverMonths.Show;
  end;

  If (cmbAuctioneers.ItemIndex > 0) AND (cmbMonth.ItemIndex > 0) then
  begin
    chkTotal.Hide;
    chkTotal.Checked := False;
  end
  else
  begin
    chkTotal.Show;
  end
end;

procedure TfrmOwner.DBChartDblClick(Sender: TObject);
begin
  DBChart.Zoomed := False;
end;

procedure TfrmOwner.FormActivate(Sender: TObject);
var
  sLastLog: string;
begin
  sLastLog := uLogin.frmLogin.UserLog;
  If Length(sLastLog) > 0 then
    lblUserLog.Caption := uLogin.frmLogin.UserLog
  else
    lblUserLog.Visible := False;

  LoadAuctioneers;
  LoadYears;
  LoadPropertyType;
  LoadLocations;
  ResetGraph;
end;

procedure TfrmOwner.LoadLocations;
var
  sSQL: string;
begin
  sSQL := 'SELECT DISTINCT Location FROM tblAuctions WHERE Location IS NOT NULL ORDER BY Location ASC';
  dmPAT_DB.runSQLB(sSQL);

  dmPAT_DB.qryB.First;
  While NOT(dmPAT_DB.qryB.Eof) do
  begin
    cmbLocation.Items.Add(dmPAT_DB.qryB['Location']);
    dmPAT_DB.qryB.Next;
  end;

end;

procedure TfrmOwner.LoadPropertyType;
var
  sSQL: string;
begin
  sSQL := 'SELECT DISTINCT Property_Type FROM tblProperties WHERE Property_Type IS NOT NULL ORDER BY Property_Type ASC';
  dmPAT_DB.runSQLB(sSQL);

  dmPAT_DB.qryB.First;
  While NOT(dmPAT_DB.qryB.Eof) do
  begin
    cmbPropertyType.Items.Add(dmPAT_DB.qryB['Property_Type']);
    dmPAT_DB.qryB.Next;
  end;
end;

procedure TfrmOwner.LoadAuctioneers;
var
  sSQL: string;
begin
  // Loads distinct Job types to combobox
  sSQL := 'SELECT (Users_Name & " " & Users_Surname) AS Full_Name ' +
    'FROM tblUsers WHERE Job_Position = "Auctioneer" ' +
    'ORDER BY (Users_Name & " " & Users_Surname) ASC';
  dmPAT_DB.runSQLB(sSQL);
  dmPAT_DB.qryB.First;
  While NOT(dmPAT_DB.qryB.Eof) do
  begin
    cmbAuctioneers.Items.Add(dmPAT_DB.qryB['Full_Name']);
    dmPAT_DB.qryB.Next;
  end;

end;

procedure TfrmOwner.LoadYears;
Var
  iCurrentYear, iLastYear: Integer;
begin
  // Loads a years to combobox until it reaches the current year
  iLastYear := strtoint(cmbYear.Items[cmbYear.Items.Count - 1]);
  iCurrentYear := CurrentYear;
  While iCurrentYear > iLastYear do
  begin
    cmbYear.Items.Add(inttostr(iLastYear + 1));
    iLastYear := iLastYear + 1;
  end;
end;

function TfrmOwner.LocationSQL: String;
begin
  If (cmbLocation.ItemIndex > 0) then
    result := ' AND tblAuctions.Location = "' + cmbLocation.Items
      [cmbLocation.ItemIndex] + '"';
end;

function TfrmOwner.MonthSQL: String;
begin
  If (cmbMonth.ItemIndex > 0) then
    result := ' AND MONTH(tblAuctions.DateTime_Auctioned) = ' +
      inttostr(cmbMonth.ItemIndex);
end;

function TfrmOwner.PropertyTypeSQL: String;
begin
  If (cmbPropertyType.ItemIndex > 0) then
    result := ' AND tblProperties.Property_Type = "' + cmbPropertyType.Items
      [cmbPropertyType.ItemIndex] + '"';
end;

function TfrmOwner.NoOverMonths_NoTotals: string;
begin
  result := 'SELECT (tblUsers.Users_Name & " " & tblUsers.Users_Surname) AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID AND tblUsers.Job_Position = "Auctioneer"'
    + AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY (tblUsers.Users_Name & " " & tblUsers.Users_Surname) ORDER BY (tblUsers.Users_Name & " " & tblUsers.Users_Surname) ASC;';
end;

function TfrmOwner.Totals_NOT_OverMonths: string;
begin
  result := 'SELECT *' + 'FROM (' +
    'SELECT (tblUsers.Users_Name & " " & tblUsers.Users_Surname) AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID ' +
    'AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID' +
    AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' AND tblUsers.Job_Position = "Auctioneer" ' +
    'GROUP BY (tblUsers.Users_Name & " " & tblUsers.Users_Surname) ' +
    'ORDER BY (tblUsers.Users_Name & " " & tblUsers.Users_Surname) ASC ' +

    'UNION '

    + 'SELECT "Total Auctioneers Commission" AS Full_Name, ROUND(SUM(tblAuctions.Winning_Bid * 7/100), 0) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID ' +
    'AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID ' +
    AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' AND tblUsers.Job_Position = "Auctioneer" ' + ') AS Results;';
end;

procedure TfrmOwner.OverMonths_1Auctioneer_1Month(var sSQL: string);
begin
  sSQL := 'SELECT DISTINCT FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID '
    + 'AND tblUsers.Job_Position = "Auctioneer"' + AuctioneerSQL + YearSQL +
    MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") ;';
end;

function TfrmOwner.OverMonths_1Auctioneer_AllMonths: string;
begin
  result := 'SELECT DISTINCT FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") AS Full_Name, MONTH(tblAuctions.DateTime_Auctioned) AS MonthNumber, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID '
    + 'AND tblUsers.Job_Position = "Auctioneer"' + AuctioneerSQL + YearSQL +
    MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY FORMAT(tblAuctions.DateTime_Auctioned, "mmmm"), MONTH(tblAuctions.DateTime_Auctioned) '
    + 'ORDER BY MONTH(tblAuctions.DateTime_Auctioned) ASC';
end;

function TfrmOwner.OverMonths_1Auctioneer_AllMonths_Totals: string;
begin
  result := 'SELECT DISTINCT FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") AS Full_Name, MONTH(tblAuctions.DateTime_Auctioned) AS MonthNumber, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID '
    + 'AND tblUsers.Job_Position = "Auctioneer"' + AuctioneerSQL + YearSQL +
    MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY FORMAT(tblAuctions.DateTime_Auctioned, "mmmm"), MONTH(tblAuctions.DateTime_Auctioned) '
    + 'ORDER BY MONTH(tblAuctions.DateTime_Auctioned) ASC';
end;

function TfrmOwner.AllMonths_AllAuctioneer_OverMonths: string;
begin
  result := 'SELECT DISTINCT FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") AS Full_Name, MONTH(tblAuctions.DateTime_Auctioned) AS MonthNumber, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID AND tblUsers.Job_Position = "Auctioneer"'
    + AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY FORMAT(tblAuctions.DateTime_Auctioned, "mmmm"),  MONTH(tblAuctions.DateTime_Auctioned) '
    + 'ORDER BY MONTH(tblAuctions.DateTime_Auctioned)';
end;

function TfrmOwner.AllMonths_AllAuctioneer_OverMonths_Totals: string;
begin
  result := 'SELECT *' + 'FROM (' +
    'SELECT DISTINCT FORMAT(tblAuctions.DateTime_Auctioned, "mmmm") AS Full_Name, MONTH(tblAuctions.DateTime_Auctioned) AS MonthNumber, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID AND tblUsers.Job_Position = "Auctioneer"'
    + AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY FORMAT(tblAuctions.DateTime_Auctioned, "mmmm"),  MONTH(tblAuctions.DateTime_Auctioned) '
    + 'UNION ' +
    'SELECT "Total Auctioneers Commission" AS Full_Name, 13 AS MonthNumber, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID ' +
    'AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID' +
    AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' AND tblUsers.Job_Position = "Auctioneer") AS Results ' +
    'ORDER BY MonthNumber ASC;';
end;

function TfrmOwner.AllAuctioneers_1Month_Total: string;
begin
  result := 'SELECT * ' + 'FROM (' +
    'SELECT DISTINCT (tblUsers.Users_Name & " " & tblUsers.Users_Surname) AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID AND tblUsers.Job_Position = "Auctioneer"'
    + AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' GROUP BY (tblUsers.Users_Name & " " & tblUsers.Users_Surname) ' + 'UNION '
    + 'SELECT "Total Auctioneers Commission" AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblUsers, tblAuctions, tblProperties ' +
    'WHERE tblAuctions.Auctioneer_ID = tblUsers.Users_ID ' +
    'AND tblAuctions.Auction_ID = tblProperties.Auction_Event_ID' +
    AuctioneerSQL + YearSQL + MonthSQL + LocationSQL + PropertyTypeSQL +
    ' AND tblUsers.Job_Position = "Auctioneer") AS Results ' +
    'ORDER BY Full_Name ASC;';
end;

procedure TfrmOwner.ResetGraph;
var
  sSQL: String;
begin
//Reset graph to auctioneers total earned
  sSQL := 'SELECT tblUsers.Users_Name & " " & tblUsers.Users_Surname AS Full_Name, SUM(tblAuctions.Winning_Bid * 7/100) AS TotalEarned '
    + 'FROM tblAuctions, tblProperties, tblUsers ' +
    'WHERE tblProperties.Auction_Event_ID = tblAuctions.Auction_ID AND tblAuctions.Auctioneer_ID = tblUsers.Users_ID '
    + 'AND Job_Position = "Auctioneer" ' +
    'GROUP BY tblUsers.Users_Name & " " & tblUsers.Users_Surname';

  dmPAT_DB.runSQL(sSQL);
  Series1.MarksOnBar := False;
  Series1.Marks.Style := smsValue;
  DBChart.Legend.TextStyle := ltsPlain;

  Series1.DataSource := dmPAT_DB.qryA;

  Series1.XLabelsSource := 'Full_Name';
  Series1.YValues.ValueSource := 'TotalEarned';

end;

function TfrmOwner.YearSQL: String;
begin
  If (cmbYear.ItemIndex > 0) then
    result := ' AND YEAR(tblAuctions.DateTime_Auctioned) = ' + cmbYear.Items
      [cmbYear.ItemIndex];
end;

end.
