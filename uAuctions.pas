unit uAuctions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.Imaging.pngimage, Vcl.WinXPickers,
  Vcl.Samples.Spin, Vcl.Buttons, Vcl.CheckLst;

type
  TfrmAuctions = class(TForm)
    imgAuctions: TImage;
    gpbAuctions: TGroupBox;
    btnEdit: TButton;
    btnLast: TButton;
    btnFirst: TButton;
    btnAuction: TButton;
    lblAuctions: TLabel;
    gpbAuctionsSearch: TGroupBox;
    btnLogout: TButton;
    cmbDateSymbols: TComboBox;
    edtWinningBid_Search2: TEdit;
    lblUserLog: TLabel;
    dPick1: TDatePicker;
    lblDate_Auction: TLabel;
    gpbAuctionInfo: TGroupBox;
    lblDate: TLabel;
    lblAuctionStatus: TLabel;
    btnAuctionSave: TButton;
    bitbtnPrevious: TBitBtn;
    bitbtnNext: TBitBtn;
    bitbtn2Previous: TBitBtn;
    bitbtn2Next: TBitBtn;
    lblCurrentAuction: TLabel;
    grpSellerInfo: TGroupBox;
    lblName: TLabel;
    lblBuyer_ID: TLabel;
    lblSurname: TLabel;
    edtSurname: TEdit;
    edtSeller_ID: TEdit;
    edtName: TEdit;
    lblAuctionLocation: TLabel;
    lblWinningBid: TLabel;
    edtWinningBid: TEdit;
    edtAuctionStatus: TEdit;
    cmbStatusSearch: TComboBox;
    lblStatusSearch: TLabel;
    dPick2: TDatePicker;
    lblBetweenDate_Search: TLabel;
    cmbWinningBidSymbols: TComboBox;
    lblWinningBid_Search: TLabel;
    edtWinningBid_Search1: TEdit;
    lblBetweenWinningBid_Search: TLabel;
    lblSellerID_Search: TLabel;
    edtSellerID_Search: TEdit;
    lblBuyerID_Search: TLabel;
    edtBuyerID_Search: TEdit;
    btnSearch: TButton;
    btnResetSearch: TButton;
    btnShowSearch: TButton;
    chkWinningBidBetween_Search: TCheckBox;
    chkDateBetween_Search: TCheckBox;
    rgbLocation: TRadioGroup;
    cmbLocation: TComboBox;
    lblTime: TLabel;
    tpTime: TTimePicker;
    dpDate: TDatePicker;
    procedure FormActivate(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure FindProperty;
    procedure btnAuctionClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnResetSearchClick(Sender: TObject);
    procedure bitbtnPreviousClick(Sender: TObject);
    procedure bitbtn2PreviousClick(Sender: TObject);
    procedure bitbtn2NextClick(Sender: TObject);
    procedure bitbtnNextClick(Sender: TObject);
    procedure btnShowSearchClick(Sender: TObject);
    procedure chkWinningBidBetween_SearchClick(Sender: TObject);
    procedure chkDateBetween_SearchClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnAuctionSaveClick(Sender: TObject);
  private
    procedure LoadSearchAuction;
    procedure SetLblCurrentAuction(iRecordChange: Integer);
    function WinningBidSQL: string;
    function DateSQL: string;
    function BuyersSQL: string;
    function SellersSQL: string;
    function StatusSQL: string;
    function LocationSQL: string;
    procedure UpdateDatabase_AuctionStatus;
    procedure ClearSearchOutput;
    procedure StatusCheck;
    procedure ResetSearch;
    procedure SetCurrentSearchBar;
    procedure SaveAuction;
    procedure LoadLocations;
    function ValidateAuction: Boolean;
    function ID_Check(sID: string): Boolean;

    { Private declarations }

  public
    { Public declarations }
    function ID_LengthCheck(sID: string): Boolean;
    function ID_OnlyNumCheck(sID: string): Boolean;
  end;

var
  frmAuctions: TfrmAuctions;

implementation

{$R *.dfm}

uses
  dmPAT_DB_U, uLogin, uAuction2;

var
  bPropertyFound: Boolean;
  iCurrentRecord: Integer;
  iNumRecord: Integer;
  sIDType: string;

procedure TfrmAuctions.bitbtn2NextClick(Sender: TObject);
begin
//Go to the next auction in query
  SetLblCurrentAuction(5);
  LoadSearchAuction;
end;

procedure TfrmAuctions.bitbtn2PreviousClick(Sender: TObject);
begin
//Go to the previous auction in query
  SetLblCurrentAuction(-5);
  LoadSearchAuction;
end;

procedure TfrmAuctions.bitbtnNextClick(Sender: TObject);
begin
//Go to the next auction in query
  SetLblCurrentAuction(1);
  LoadSearchAuction;
end;

procedure TfrmAuctions.bitbtnPreviousClick(Sender: TObject);
begin
//Go to the previos auction in query
  SetLblCurrentAuction(-1);
  LoadSearchAuction;
end;

procedure TfrmAuctions.btnAuctionClick(Sender: TObject);
begin
//find corresponding info(records) in DB
  FindProperty;
  dmPAT_DB.tblAuctions.Locate('Auction_ID', dmPAT_DB.qryA['Auction_ID'], []);

  frmAuction2.show;
  frmAuctions.hide;
end;

procedure TfrmAuctions.btnEditClick(Sender: TObject);
begin
//Allow auctioneer to change auction info
  LoadLocations;
  btnAuctionSave.Visible := True;
  gpbAuctionInfo.Enabled := True;
end;

procedure TfrmAuctions.btnFirstClick(Sender: TObject);
begin
//Go to the first auction in query
  dmPAT_DB.qryA.First;
  LoadSearchAuction;
  iCurrentRecord := 1;
  lblCurrentAuction.Caption := inttostr(iCurrentRecord) + ' / ' +
    inttostr(iNumRecord);
end;

procedure TfrmAuctions.btnLastClick(Sender: TObject);
begin
  dmPAT_DB.qryA.Last;
  LoadSearchAuction;
  iCurrentRecord := iNumRecord;
  lblCurrentAuction.Caption := inttostr(iCurrentRecord) + ' / ' +
    inttostr(iNumRecord);
end;

procedure TfrmAuctions.btnLogoutClick(Sender: TObject);
begin
  frmLogin.Logout;
  frmLogin.show;
  frmAuctions.Close;
end;

procedure TfrmAuctions.btnAuctionSaveClick(Sender: TObject);
begin
//Save the new auction information and reset sql and search
  If (dmPAT_DB.tblAuctions.Locate('Auction_ID', dmPAT_DB.qryA['Auction_ID'], [])
    = False) then
  begin
    ShowMessage('The auction has not been found in the database.');
    Exit;
  end;
  If ValidateAuction = False then
    Exit;

  SaveAuction;
  ShowMessage('The auction has been edited successfully.');

  btnAuctionSave.Visible := False;
  ResetSearch;
  SetCurrentSearchBar;
  LoadSearchAuction;
end;

function TfrmAuctions.WinningBidSQL: string;
var
  sTemp: String;
begin
//Create Winning Bid SQL if it passes verification
  If chkWinningBidBetween_Search.Checked = True then
  begin
    If strtoint(edtWinningBid_Search2.Text) <
      strtoint(edtWinningBid_Search1.Text) then
    begin
      sTemp := edtWinningBid_Search2.Text;
      edtWinningBid_Search2.Text := edtWinningBid_Search1.Text;
      edtWinningBid_Search1.Text := sTemp;
    end;

    result := ' AND tblAuctions.Winning_Bid > ' + edtWinningBid_Search1.Text +
      ' AND tblAuctions.Winning_Bid < ' + edtWinningBid_Search2.Text;
  end
  else If (cmbWinningBidSymbols.ItemIndex > 0) then
  begin
    result := ' AND tblAuctions.Winning_Bid ' + cmbWinningBidSymbols.Items
      [cmbWinningBidSymbols.ItemIndex] + edtWinningBid_Search1.Text;
  end;
end;

function TfrmAuctions.DateSQL: string;
var
  dTemp: TDate;
begin
//Create Date SQL if it passes verification
  If chkDateBetween_Search.Checked = True then
  begin
    If (dPick1.Date > dPick2.Date) then
    begin
      dTemp := dPick1.Date;
      dPick1.Date := dPick2.Date;
      dPick2.Date := dTemp;
    end;

    result := ' AND tblAuctions.DateTime_Auctioned > #' + datetostr(dPick1.Date)
      + '# AND tblAuctions.DateTime_Auctioned < #' +
      datetostr(dPick2.Date) + '#';
  end
  else
  begin
    If (cmbDateSymbols.ItemIndex > 0) then
      result := ' AND tblAuctions.DateTime_Auctioned ' + cmbDateSymbols.Items
        [cmbDateSymbols.ItemIndex] + ' #' + datetostr(dPick1.Date) + '#';
  end;
end;

procedure TfrmAuctions.btnResetSearchClick(Sender: TObject);
begin
//Reset window to how it was first initialized
  ResetSearch;
  SetCurrentSearchBar;
  LoadSearchAuction;

  ClearSearchOutput;

  // Change GUI to hide Search
  gpbAuctionsSearch.Visible := False;
  btnShowSearch.show;
  frmAuctions.Height := 440;
  btnLogout.top := 370;
end;

procedure TfrmAuctions.btnSearchClick(Sender: TObject);
var
  sSQL: string;
begin
//Create and run search based on the inputted variables
  UpdateDatabase_AuctionStatus;

  sSQL := 'SELECT tblAuctions.DateTime_Auctioned, tblAuctions.Location, tblAuctions.Status, tblAuctions.Winning_Bid, tblAuctions.Buyers_ID,'
    + ' tblProperties.Address, tblProperties.Seller_Prop_ID, tblProperties.Property_Type,'
    + ' tblSellers.Seller_ID, tblSellers.Sellers_Name, tblSellers.Sellers_Surname'
    + ' FROM tblAuctions, tblProperties, tblSellers' +
    ' WHERE tblProperties.Auction_Event_ID = tblAuctions.Auction_ID AND tblSellers.Seller_ID = tblProperties.Seller_Prop_ID AND tblAuctions.Auctioneer_ID = "'
    + uLogin.frmLogin.arrUsers[uLogin.frmLogin.iArrPos].getID + '"' +
    WinningBidSQL + DateSQL + StatusSQL + LocationSQL + SellersSQL + BuyersSQL;

  dmPAT_DB.runSQLB(sSQL);
  If (dmPAT_DB.qryB.RecordCount > 0) then
  begin
    dmPAT_DB.runSQL(sSQL);
    SetCurrentSearchBar;
    LoadSearchAuction;

    // Change GUI to hide Search
    gpbAuctionsSearch.Visible := False;
    btnShowSearch.show;
    frmAuctions.Height := 440;
    btnLogout.top := 370;
  end
  else
    ShowMessage('Your search failed as no auction matches your search.');
end;

procedure TfrmAuctions.btnShowSearchClick(Sender: TObject);
begin
//Show search group box
  frmAuctions.Height := 678;
  frmAuctions.ClientHeight := 639;
  btnLogout.top := 607;
  lblUserLog.top := 607;
  btnShowSearch.hide;
  gpbAuctionsSearch.show;

end;

function TfrmAuctions.BuyersSQL: string;
begin
//Create buyer SQL if it passes verification
  If Length(edtBuyerID_Search.Text) > 0 then
  begin
    sIDType := 'Buyer';
    If (ID_Check(edtBuyerID_Search.Text) = True) then
    begin
      result := ' AND tblAuctions.Buyers_ID = ' + edtBuyerID_Search.Text;
    end
    else
      result := '';
  end;
end;

procedure TfrmAuctions.chkDateBetween_SearchClick(Sender: TObject);
begin
//Allow for a date range
  If chkDateBetween_Search.Checked = False then
  begin
    lblBetweenDate_Search.hide;
    dPick2.hide;
    cmbDateSymbols.show;
  end
  else
  begin
    lblBetweenDate_Search.show;
    dPick2.show;
    cmbDateSymbols.hide;
  end;
end;

procedure TfrmAuctions.chkWinningBidBetween_SearchClick(Sender: TObject);
begin
  // Hide between and show between
  If chkWinningBidBetween_Search.Checked = False then
  begin
    cmbWinningBidSymbols.show;
    lblBetweenWinningBid_Search.hide;
    edtWinningBid_Search2.hide;
    edtWinningBid.TextHint := 'Winning Bid';
  end
  else
  begin
    cmbWinningBidSymbols.hide;
    lblBetweenWinningBid_Search.show;
    edtWinningBid_Search2.show;
    edtWinningBid.TextHint := 'Min Winning Bid';
  end;
end;

procedure TfrmAuctions.ClearSearchOutput;
begin
  //Resets the search to when the user logs in
  cmbWinningBidSymbols.show;
  lblBetweenWinningBid_Search.hide;
  edtWinningBid_Search2.hide;
  cmbWinningBidSymbols.TextHint := 'Symbols';
  edtWinningBid_Search1.TextHint := 'Min winning bid';
  edtWinningBid_Search2.TextHint := 'Max winning bid';
  chkWinningBidBetween_Search.Checked := False;

  cmbDateSymbols.show;
  lblBetweenDate_Search.hide;
  dPick2.hide;
  cmbDateSymbols.TextHint := 'Symbols';
  chkDateBetween_Search.Checked := False;

  edtSellerID_Search.Clear;
  edtBuyerID_Search.Clear;
  rgbLocation.ItemIndex := 0;
end;

procedure TfrmAuctions.StatusCheck;
begin
//Hide edit if the status is not completed
  if dmPAT_DB.qryA['Status'] = 'Completed' then
  begin
    btnEdit.show;
    btnAuction.hide;
    edtWinningBid.Enabled := True;
  end
  else
  begin
    btnEdit.hide;
    btnAuction.show;
    edtWinningBid.Enabled := False;
  end;
end;

procedure TfrmAuctions.FindProperty;
begin
  // Find the correlating record using the foreign key
  With dmPAT_DB do
  begin
    tblProperties.First;
    bPropertyFound := True;

    While (tblProperties['Auction_Event_ID'] <> tblAuctions['Auction_ID']) AND
      NOT(tblProperties.Eof) do
    begin
      tblProperties.Next;

      IF tblProperties.Eof then
      begin
        ShowMessage('Error: Property not found in the database');
        bPropertyFound := False;
      end;
    end;

  end;
end;

procedure TfrmAuctions.FormActivate(Sender: TObject);
var
  sLastLog: string;
begin
  // Load last logged in
  sLastLog := uLogin.frmLogin.UserLog;
  If Length(sLastLog) > 0 then
    lblUserLog.Caption := uLogin.frmLogin.UserLog
  else
    lblUserLog.Visible := False;

  // Load search variables
  UpdateDatabase_AuctionStatus;
  LoadLocations;

  ResetSearch;
  LoadSearchAuction;
  SetCurrentSearchBar;

  frmAuctions.Height := 479;
  btnLogout.top := 368;
  lblUserLog.top := 368;
  frmAuctions.ClientHeight := 440;

end;

function TfrmAuctions.ID_Check(sID: string): Boolean;
begin
//Verify ID length and only numbers
  result := True;
  If (ID_LengthCheck(sID) = False) then
  begin
    ShowMessage('The ' + sIDType +
      ' Id is not the correct length and was therefore removed from the search.');
    result := False;
    Exit;
  end;
  If ID_OnlyNumCheck(sID) = False then
  begin
    ShowMessage('The ' + sIDType +
      ' Id must have numbers in, it does not only have numbers in and eas therefore removed from the search.');
    result := False;
    Exit;
  end;

end;

function TfrmAuctions.ID_OnlyNumCheck(sID: string): Boolean;
var
  iID_Count: Integer;
  iID_Length: Integer;
begin
  // Check if ID has only numbers in
  result := True;
  iID_Length := Length(sID);
  iID_Count := 1;
  while (iID_Count < iID_Length) and (result = True) do
  begin
    if not(Charinset(sID[iID_Count], ['0' .. '9'])) then
      result := False;
    Inc(iID_Count);
  end;
end;

function TfrmAuctions.ID_LengthCheck(sID: string): Boolean;
var
  iID_Length: Integer;
begin
  result := True;
  // Check ID length
  iID_Length := Length(sID);
  if (iID_Length <> 13) then
  begin
    result := False;
  end;
end;

procedure TfrmAuctions.ResetSearch;
var
  sSQL: string;
begin
//Reset SQL to only show the auctioneer's auctions
  sSQL := 'SELECT tblAuctions.Auction_ID, tblAuctions.DateTime_Auctioned, tblAuctions.Location, tblAuctions.Status, tblAuctions.Winning_Bid, tblAuctions.Buyers_ID,'
    + ' tblProperties.Address, tblProperties.Seller_Prop_ID, tblProperties.Property_Type,'
    + ' tblSellers.Seller_ID, tblSellers.Sellers_Name, tblSellers.Sellers_Surname'
    + ' FROM tblAuctions, tblProperties, tblSellers' +
    ' WHERE tblProperties.Auction_Event_ID = tblAuctions.Auction_ID AND tblSellers.Seller_ID = tblProperties.Seller_Prop_ID'
    + ' AND tblAuctions.Auctioneer_ID = "' + uLogin.frmLogin.arrUsers
    [uLogin.frmLogin.iArrPos].getID + '"';
  dmPAT_DB.runSQL(sSQL);
end;

procedure TfrmAuctions.SetCurrentSearchBar;
begin
  //Sets the serch bar
  iNumRecord := dmPAT_DB.qryA.RecordCount;
  dmPAT_DB.qryA.First;
  lblCurrentAuction.Caption := '1 / ' + inttostr(iNumRecord);
end;

procedure TfrmAuctions.LoadLocations;
var
  sSQL: string;
begin
//Run a query to get distinct locations
  sSQL := 'SELECT DISTINCT Location FROM tblAuctions WHERE Location IS NOT NULL ORDER BY Location ASC';
  dmPAT_DB.runSQLB(sSQL);

  dmPAT_DB.qryB.First;
  While NOT(dmPAT_DB.qryB.Eof) do
  begin
    cmbLocation.Items.Add(dmPAT_DB.qryB['Location']);
    dmPAT_DB.qryB.Next;
  end;
end;

procedure TfrmAuctions.LoadSearchAuction;
begin
  dpDate.Date := (dmPAT_DB.qryA['DateTime_Auctioned']);
  edtAuctionStatus.Text := dmPAT_DB.qryA['Status'];

  IF dmPAT_DB.qryA['Winning_Bid'] <> NULL then
    edtWinningBid.Text := dmPAT_DB.qryA['Winning_Bid']
    // NULL if upcoming OR ongoing
  else
    edtWinningBid.Text := 'Pending';

  If dmPAT_DB.qryA['Location'] <> NULL then
    cmbLocation.Text := dmPAT_DB.qryA['Location']
  else
    cmbLocation.Text := 'Pending';

  // Load seller info
  edtSurname.Text := dmPAT_DB.qryA['Sellers_Surname'];;
  edtName.Text := dmPAT_DB.qryA['Sellers_Name'];
  edtSeller_ID.Text := dmPAT_DB.qryA['Seller_ID'];

  StatusCheck;
end;

function TfrmAuctions.LocationSQL: string;
begin
  if (rgbLocation.ItemIndex > 0) then
  begin
    result := ' AND tblAuctions.Location = "' + rgbLocation.Items
      [rgbLocation.ItemIndex] + '"';
  end;
end;

procedure TfrmAuctions.SaveAuction;
begin
//Saves Auction info
  With dmPAT_DB do
  begin
    tblAuctions.Edit;
    dmPAT_DB.tblAuctions['Auctioneer_ID'] := frmLogin.arrUsers
      [frmLogin.iArrPos].getID;
    tblAuctions['Status'] := cmbLocation.Items[cmbLocation.ItemIndex];
    tblAuctions['DateTime_Auctioned'] :=
      StrToDateTime(datetostr(dpDate.Date) + ' ' + TimeToStr(tpTime.Time));
    tblAuctions.Post;
  end;
end;

function TfrmAuctions.SellersSQL: string;
//Create seller SQL if passes vefification
begin
  sIDType := 'Seller';
  If Length(edtSellerID_Search.Text) > 0 then
  begin
    If (ID_Check(edtSellerID_Search.Text) = True) then
    begin
      result := ' AND tblProperties.Seller_Prop_ID = ' +
        edtSellerID_Search.Text;
    end
    else
      result := '';
  end;
end;

procedure TfrmAuctions.SetLblCurrentAuction(iRecordChange: Integer);
var
  iRecordLoop: Integer;
begin
  //Change current record based on the button clicked, if it exceeds the max/min,
  //    it will begin at the opposite of the max/min, then changes current auction

  If (iCurrentRecord + iRecordChange) > iNumRecord then
  begin
    dmPAT_DB.qryA.First;
    iCurrentRecord := 1;

    lblCurrentAuction.Caption := '1 / ' + inttostr(iNumRecord);
  end
  else If (iCurrentRecord + iRecordChange) < 1 then
  begin
    dmPAT_DB.qryA.Last;
    iCurrentRecord := iNumRecord;

    lblCurrentAuction.Caption := inttostr(iNumRecord) + ' / ' +
      inttostr(iNumRecord);
  end
  else If iRecordChange > 0 then
  begin
    For iRecordLoop := 1 to iRecordChange do
    begin
      dmPAT_DB.qryA.Next;
      Inc(iCurrentRecord);

      lblCurrentAuction.Caption := inttostr(iCurrentRecord) + ' / ' +
        inttostr(iNumRecord);
    end;
  end
  else
  begin
    For iRecordLoop := 1 to (iRecordChange * -1) do
    begin
      dmPAT_DB.qryA.Prior;
      Dec(iCurrentRecord);

      lblCurrentAuction.Caption := inttostr(iCurrentRecord) + ' / ' +
        inttostr(iNumRecord);
    end;
  end;

end;

function TfrmAuctions.StatusSQL: string;
begin
////Create auctionn status SQL if passes vefification (has been selected)
  If cmbStatusSearch.ItemIndex > -1 then
    result := ' AND tblAuctions.Status = "' + cmbStatusSearch.Items
      [cmbStatusSearch.ItemIndex] + '"';
end;

procedure TfrmAuctions.UpdateDatabase_AuctionStatus;
var
  sSQL: string;
begin
//Create a query fo upcoming and update it to ongoing if it has/is starting/started according to the
// start datetime in DB
  sSQL := 'SELECT tblAuctions.Auction_ID' + ' FROM tblAuctions' +
    ' WHERE tblAuctions.Status = "Upcoming" AND tblAuctions.DateTime_Auctioned <= '
    + datetostr(Now());
  dmPAT_DB.runSQLB(sSQL);

  If dmPAT_DB.qryB.RecordCount > 0 then
  begin
    dmPAT_DB.qryB.First;
    While NOT(dmPAT_DB.qryB.Eof) do
    begin
      With dmPAT_DB do
      begin
        tblAuctions.Locate('Auction_ID', dmPAT_DB.qryB['Auction_ID'], []);
        tblAuctions.Edit;
        tblAuctions['Status'] := 'Ongoing';
        tblAuctions.Post;
      end;
      dmPAT_DB.qryB.Next;
    end;
    ShowMessage('An auction is currently ongoing.  Please proceed to auction it.');
  end;
end;

function TfrmAuctions.ValidateAuction: Boolean;
begin
//Validate the new auction information
  result := True;
  If dmPAT_DB.qryA['Status'] = 'Upcoming' then
  begin
    If (StrToDateTime(datetostr(dpDate.Date) + ' ' + TimeToStr(tpTime.Time)) <
      Now()) then
    begin
      ShowMessage
        ('Please make sure the date and time for the auction is later than today.');
      result := False;
      Exit;
    end
  end
  else
  begin
    If (StrToDateTime(datetostr(dpDate.Date) + ' ' + TimeToStr(tpTime.Time)) >
      Now()) then
    begin
      ShowMessage
        ('Please make sure the date and time for the auction is earlier than today.');
      result := False;
      Exit;
    end
  end;
  If cmbLocation.ItemIndex <= 0 then
  begin
    ShowMessage('Please make sure thhat you have selected a location.');
    result := False;
    Exit;
  end;
  If edtAuctionStatus.Text = 'Completed' then
  begin
    If (strtoint(edtWinningBid.Text) < 1000000) then
    begin
      ShowMessage
        ('Please make sure that the winning bid is at least a million (R1 000 000) rand.');
      result := False;
      Exit;
    end;
  end;
end;

end.
