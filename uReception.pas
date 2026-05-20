unit uReception;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Samples.Spin,
  System.UITypes, Math, Vcl.WinXPickers;

type
  TfrmReception = class(TForm)
    imgReception: TImage;
    lblAuctions: TLabel;
    btnLogout: TButton;
    gpbSellerInfo: TGroupBox;
    lblName: TLabel;
    lblContactNumber: TLabel;
    lblEmail: TLabel;
    lblBuyer_ID: TLabel;
    lblSurname: TLabel;
    lblAccept_Terms: TLabel;
    edtEmail: TEdit;
    edtContactNumber: TEdit;
    edtSurname: TEdit;
    edtSeller_ID: TEdit;
    edtName: TEdit;
    chkAccept_Terms: TCheckBox;
    gpbPropInfo: TGroupBox;
    lblPropAddress: TLabel;
    lblNumBedrooms: TLabel;
    lblNumBathrooms: TLabel;
    lblFloorArea: TLabel;
    lblPropertyType: TLabel;
    edtPropertyAddress: TEdit;
    btnPropSave: TButton;
    lblNumGarages: TLabel;
    sedBedrooms: TSpinEdit;
    sedBathrooms: TSpinEdit;
    sedGarages: TSpinEdit;
    cmbPropType: TComboBox;
    edtArea: TEdit;
    lblSell_ID_Search: TLabel;
    edtSell_ID_Search: TEdit;
    btnSell_ID_Search: TButton;
    btnSellerSave: TButton;
    lblUserLog: TLabel;
    lblReservePrice: TLabel;
    edtReservePrice: TEdit;
    btnRegisterProp: TButton;
    btnBack: TButton;
    lblAuctionLocation: TLabel;
    cmbLocation: TComboBox;
    lblAuctioneerID: TLabel;
    edtAucioneerID: TEdit;
    lblDate: TLabel;
    lblTime: TLabel;
    dpDate: TDatePicker;
    tpTime: TTimePicker;
    procedure FormActivate(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure btnSell_ID_SearchClick(Sender: TObject);
    procedure LoadSellerInfo;
    procedure LoadPropAddressInfo;
    procedure ID_LengthCheck;
    procedure btnPropSaveClick(Sender: TObject);
    procedure AddProperty(sAddress, sFloorArea, sID: String;
      iBathrooms, iBedrooms, iGarages: Integer);
    procedure btnSellerSaveClick(Sender: TObject);
    procedure btnRegisterPropClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
  private
    { Private declarations }
    function ValidatePropInfo(sAddress, sFloorArea, sID: String;
      iBathrooms, iBedrooms, iGarages: Integer): Boolean;
    procedure AddSeller;

  var
    bEditSeller: Boolean;

  public
    { Public declarations }
    function ValidateSellerInfo(sName, sSurname, sCellnumber, sID,
      sEmail: string): Boolean;
  end;

var
  frmReception: TfrmReception;

implementation

{$R *.dfm}

Uses
  dmPAT_DB_U, uLogin, uAuctions;

procedure TfrmReception.AddProperty(sAddress, sFloorArea, sID: String;
  iBathrooms, iBedrooms, iGarages: Integer);
var
  sSQL: String;
  dArea: Double;
  cReservePrice: Currency;
begin
  dArea := StrToFloat(sFloorArea);
  If dmPAT_DB.tblSellers.Locate('Seller_ID', edtSeller_ID.Text, []) = False then
    AddSeller;
  If (Length(edtReservePrice.Text) > 0) then
    cReservePrice := StrToCurr(edtReservePrice.Text)
  else
    cReservePrice := 0;
  With dmPAT_DB do
  begin
    sSQL := 'SELECT MAX(Auction_Event_ID) AS LastID ' + 'FROM tblProperties';
    runSQLB(sSQL);

    tblAuctions.Insert;
    tblAuctions['Auction_ID'] := qryB['LastID'] + 1;
    tblAuctions['Status'] := 'Upcoming';
    tblAuctions.Post;

    tblProperties.Insert;
    tblProperties['Auctioneer_ID'] := sID;
    tblProperties['Address'] := sAddress;
    tblProperties['Property_Type'] := cmbPropType.Items[cmbPropType.ItemIndex];
    tblProperties['Square_Footage'] := RoundTo(dArea, 2);
    tblProperties['Bedrooms'] := iBedrooms;
    tblProperties['Bathrooms'] := iBathrooms;
    tblProperties['Garages'] := iGarages;
    tblProperties['Reserve_Price'] := cReservePrice;
    tblProperties['Seller_Prop_ID'] := edtSeller_ID.Text;
    tblProperties['DateTime_Auctioned'] := DateToStr(dpDate.Date) + ' ' +
      TimeToStr(tpTime.Time);

    tblProperties['Auction_Event_ID'] := strtoint(qryB['LastID']) + 1;
    tblProperties.Post;

  end;
  ShowMessage('Property was added successfully.');
end;

procedure TfrmReception.AddSeller;
begin
  begin
    with dmPAT_DB do
    begin
      If bEditSeller = True then
        tblSellers.Edit
      else
        tblSellers.Insert;

      If bEditSeller = False then
        tblSellers['Seller_ID'] := edtSeller_ID.Text;

      tblSellers['Sellers_Name'] := edtName.Text;
      tblSellers['Sellers_Surname'] := edtSurname.Text;
      tblSellers['Seller_Cell_Number'] := edtContactNumber.Text;
      tblSellers['Email'] := edtEmail.Text;
      tblSellers.Post;
    end;
    If bEditSeller = False then
      ShowMessage('Seller was added successfully.')
    else
      ShowMessage('Seller was edited successfully.')
  end;
  bEditSeller := False;
end;

procedure TfrmReception.btnBackClick(Sender: TObject);
begin
  frmReception.Width := 750;
  gpbPropInfo.Hide;
  gpbSellerInfo.Enabled := True;

end;

procedure TfrmReception.btnLogoutClick(Sender: TObject);
begin
  frmLogin.Logout;
  frmLogin.Show;
  frmReception.Close;
end;

procedure TfrmReception.btnPropSaveClick(Sender: TObject);
var
  sAddress, sFloorArea: String;
  iBathrooms, iBedrooms, iGarages: Integer;
  sID: String;
begin
  sAddress := edtPropertyAddress.Text;
  sFloorArea := edtArea.Text;
  iBathrooms := sedBathrooms.Value;
  iBedrooms := sedBedrooms.Value;
  iGarages := sedGarages.Value;
  sID := edtAucioneerID.Text;

  if ValidatePropInfo(sAddress, sFloorArea, sID, iBathrooms, iBedrooms,
    iGarages) = False then
    exit;

    if dmPAT_DB.tblUsers.Locate('Users_ID', sID, []) then
  begin
    ShowMessage
      ('The ID of an active auctioneer was not found with the inputted ID.');
    exit
  end;

  if (MessageDlg('Are you sure you want to add a new property, with ' +
    edtName.Text + ' ' + edtSurname.Text + 'as the seller of the property?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes) then
  begin
    AddProperty(sAddress, sFloorArea, sID, iBathrooms, iBedrooms, iGarages);
    gpbPropInfo.Hide;
    Self.Width := 600;
  end;
end;

procedure TfrmReception.btnRegisterPropClick(Sender: TObject);
begin
  If (dmPAT_DB.tblSellers.Locate('Seller_ID', edtSeller_ID.Text, []) = True)
  then
  begin
    frmReception.Width := 1425;
    gpbPropInfo.Visible := True;
    gpbSellerInfo.Show;
    gpbPropInfo.Refresh;
  end
  else
    ShowMessage
      ('The seller ID was not found in the database, please make sure the seller ID is correct.');
end;

procedure TfrmReception.btnSellerSaveClick(Sender: TObject);
var
  sName, sSurname, sCellnumber, sID, sEmail: string;
begin
  sName := edtName.Text;
  sSurname := edtSurname.Text;
  sCellnumber := edtContactNumber.Text;
  sID := edtSeller_ID.Text;
  sEmail := edtEmail.Text;

  If (chkAccept_Terms.Checked = False) then
  begin
    ShowMessage('The seller must accept the terms and conditions to proceed.');
    exit;
  end;

  If ValidateSellerInfo(sName, sSurname, sCellnumber, sID, sEmail) = False then
    exit;

  If dmPAT_DB.tblSellers.Locate('Seller_ID', edtSell_ID_Search.Text, []) = True
  then
  begin
    if (MessageDlg
      ('A seller already exists with this ID number, do you wish to update it with the current information?',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes) then
      bEditSeller := True
    else
      exit;
  end;

  AddSeller;
end;

procedure TfrmReception.btnSell_ID_SearchClick(Sender: TObject);
var
  sID_SellerSearch: String;
begin
  sID_SellerSearch := edtSell_ID_Search.Text;

  // Search for seller ID, if found then load
  If (frmAuctions.ID_LengthCheck(sID_SellerSearch) = False) then
  begin
    ShowMessage('Please make sure the seller ID is 13 digits long.');
  end
  else
  begin
    If (frmAuctions.ID_OnlyNumCheck(sID_SellerSearch) = False) then
      ShowMessage('Please make sure the seller ID only consists of numbers.');
  end;
  If dmPAT_DB.tblSellers.Locate('Seller_ID', edtSell_ID_Search.Text, []) = True
  then
  begin
    LoadSellerInfo;
    ShowMessage('Seller has been loaded successfully.');
    gpbPropInfo.Show;
  end
  else
    ShowMessage('Seller ID not found.');

end;

procedure TfrmReception.FormActivate(Sender: TObject);
var
  sLastLog: string;
begin
  gpbPropInfo.Hide;
  frmReception.Width := 750;
  sLastLog := uLogin.frmLogin.UserLog;
  If Length(sLastLog) > 0 then
    lblUserLog.Caption := uLogin.frmLogin.UserLog
  else
    lblUserLog.Visible := False;
  bEditSeller := False;
end;

procedure TfrmReception.ID_LengthCheck;
begin

  If Length(edtSell_ID_Search.Text) <> 13 then
  begin
    ShowMessage
      ('The inputted seller ID number is the incorrect length, please enter a 13 digit ID number.');
  end;

end;

procedure TfrmReception.LoadPropAddressInfo;
begin
  edtPropertyAddress.Text := dmPAT_DB.tblProperties['Address'];
  edtArea.Text := dmPAT_DB.tblProperties['Square_Footage'];
  sedBedrooms.Text := dmPAT_DB.tblProperties['Bedrooms'];
  sedBathrooms.Text := dmPAT_DB.tblProperties['Bathrooms'];
  sedGarages.Text := dmPAT_DB.tblProperties['Garages'];

  // Check property type for combobox
  if cmbPropType.Items[0] = dmPAT_DB.tblProperties['Property_Type'] then
    cmbPropType.ItemIndex := 0
  else
    cmbPropType.ItemIndex := 1
end;

procedure TfrmReception.LoadSellerInfo;
begin
  edtName.Text := dmPAT_DB.tblSellers['Sellers_Name'];
  edtSurname.Text := dmPAT_DB.tblSellers['Sellers_Surname'];
  edtEmail.Text := dmPAT_DB.tblSellers['Email'];
  edtContactNumber.Text := dmPAT_DB.tblSellers['Seller_Cell_Number'];
  edtSeller_ID.Text := dmPAT_DB.tblSellers['Seller_ID'];
  chkAccept_Terms.Checked := True;
end;

function TfrmReception.ValidatePropInfo(sAddress, sFloorArea, sID: String;
  iBathrooms, iBedrooms, iGarages: Integer): Boolean;
var
  iLoop: Integer;
  sTemp: String;
  iCommaPos: Integer;
begin
  Result := True;
  If (Length(sAddress) < 10) then
  begin
    ShowMessage('Please make sure the adress is at least 10 letters long.');
    Result := False;
    exit
  end
  else If (Length(sFloorArea) < 2) then
  begin
    ShowMessage
      ('Please make sure you have inputted a floor area with at least 2 digits.');
    Result := False;
    exit
  end
  else
    For iLoop := 1 to Length(sFloorArea) do
    begin
      If NOT(CharInSet(sFloorArea[iLoop], ['0' .. '9'])) AND
        NOT(sFloorArea[iLoop] = ',') then
      begin
        ShowMessage
          ('Please make sure your floor area is only numbers or a comma(",")');
        Result := False;
        exit;
      end;
    end;
  sTemp := sFloorArea;
  iCommaPos := Pos(',', sTemp);
  If (iCommaPos > 0) then
    Delete(sTemp, iCommaPos, 1);
  If (Pos(',', sTemp) > 0) then
  begin
    ShowMessage
      ('Please make sure there is only one comma(",") in the floor area.');
    Result := False;
    exit
  end
  else If (cmbPropType.ItemIndex < 0) then
  begin
    ShowMessage('Please make sure that you have selected a property type.');
    Result := False;
    exit
  end
  else if frmAuctions.ID_LengthCheck(sID) = False then
  begin
    ShowMessage('Please make sure the auctioneer ID is 13 digits long');
    Result := False;
    exit
  end
  else if frmAuctions.ID_OnlyNumCheck(sID) = False then
  begin
    ShowMessage('Please make sure the auctioneer ID consists of numbers only.');
    Result := False;
    exit
  end;
  IF dpDate.Date <= Now() then
  begin
    ShowMessage
      ('Please make sure the date for the auction is later than todays date.');
    Result := False;
    exit
  end;
end;

function TfrmReception.ValidateSellerInfo(sName, sSurname, sCellnumber, sID,
  sEmail: string): Boolean;
begin
  Result := True;
  If (Length(sName) = 0) then
  begin
    ShowMessage
      ('Please make sure the sellers name is at least 1 letter long."');
    Result := False;
    exit
  end
  else If (Pos(' ', sName) > 0) then
  begin
    ShowMessage('Please make sure the sellers name has no spaces in it."');
    Result := False;
    exit
  end
  else If (Length(sSurname) = 0) then
  begin
    ShowMessage
      ('Please make sure the sellers surname is at least 1 letter long."');
    Result := False;
    exit
  end
  else If (Length(sCellnumber) <> 10) then
  begin
    ShowMessage
      ('Please make sure the sellers contact number is 10 digits long."');
    Result := False;
    exit
  end
  else If (sCellnumber[1] <> '0') then
  begin
    ShowMessage
      ('Please make sure the sellers contact number starts with a "0"."');
    Result := False;
    exit
  end
  else If (frmAuctions.ID_LengthCheck(sID) = False) then
  begin
    ShowMessage('Please make sure the seller ID is 13 digits long.');
    Result := False;
    exit
  end
  else If (frmAuctions.ID_OnlyNumCheck(sID) = False) then
  begin
    ShowMessage('Please make sure the seller ID only consists of numbers.');
    Result := False;
    exit
  end
  else If (Length(sEmail) < 10) then
  begin
    ShowMessage
      ('Please make sure that the sellers email address has at least 10 letters in.');
    Result := False;
    exit
  end
  else If (Pos('@', sEmail) < 1) then
  begin
    ShowMessage
      ('Please make sure that the sellers email address has an "@" symbol in.');
    Result := False;
    exit
  end
end;

end.
