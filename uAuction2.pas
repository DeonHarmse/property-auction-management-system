unit uAuction2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, System.UITypes;

type
  TfrmAuction2 = class(TForm)
    imgAuction2: TImage;
    grpAuctionDetails: TGroupBox;
    grpBuyerInfo: TGroupBox;
    lblReserve: TLabel;
    edtEmail: TEdit;
    edtContactNumber: TEdit;
    edtSurname: TEdit;
    edtBuyer_ID: TEdit;
    edtName: TEdit;
    lblName: TLabel;
    lblContactNumber: TLabel;
    lblEmail: TLabel;
    lblBuyer_ID: TLabel;
    lblSurname: TLabel;
    lblOngoingAuction: TLabel;
    lblCurrentBid: TLabel;
    edtCurrentBid: TEdit;
    btnSold: TButton;
    lblAccept_Terms: TLabel;
    chkAccept_Terms: TCheckBox;
    btnSave: TButton;
    btnBack: TButton;
    lblBuy_ID_Search: TLabel;
    edtBuy_ID_Search: TEdit;
    btnBuy_ID_Search: TButton;
    edtReservePrice: TEdit;
    lblStartingBid: TLabel;
    edtStartingBid: TEdit;
    imgBedrooms: TImage;
    imgBathrooms: TImage;
    imgGarages: TImage;
    lblBedrooms: TLabel;
    lblBathrooms: TLabel;
    lblGarages: TLabel;
    imgLocation: TImage;
    imgType: TImage;
    lblLocation: TLabel;
    lblType: TLabel;
    imgSquareFootage: TImage;
    lblSquareFootage: TLabel;
    btnLogout: TButton;
    lbl3ndBidInc: TLabel;
    lbl1stBidInc: TLabel;
    lbl2ndBidInc: TLabel;
    lbl3rdBidDec: TLabel;
    lbl1stBidDec: TLabel;
    lbl2ndBidDec: TLabel;
    img2ndBidInc: TBitBtn;
    img3rdBidInc: TBitBtn;
    img3rdBidDec: TBitBtn;
    img2ndBidDec: TBitBtn;
    img1stBidInc: TBitBtn;
    img1stBidDec: TBitBtn;
    procedure btnBackClick(Sender: TObject);
    procedure btnBuy_ID_SearchClick(Sender: TObject);
    procedure LoadBuyerInfo;
    procedure FormActivate(Sender: TObject);
    procedure PropertyDescription;
    procedure btnSoldClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure img3rdBidIncClick(Sender: TObject);
    procedure img3rdBidDecClick(Sender: TObject);
    procedure img2ndBidIncClick(Sender: TObject);
    procedure img1stBidIncClick(Sender: TObject);
    procedure img2ndBidDecClick(Sender: TObject);
    procedure img1stBidDecClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
    procedure AddBuyer;
  public
    { Public declarations }
  end;

var
  frmAuction2: TfrmAuction2;

implementation

{$R *.dfm}

Uses
  uLogin, uAuctions, uReception, dmPAT_DB_U;

var
  cCurrentBid: Currency;
  bEditBuyer: Boolean;

procedure TfrmAuction2.AddBuyer;
begin
  begin
    with dmPAT_DB do
    begin
      If bEditBuyer = True then
        tblBuyers.Edit
      else
        tblBuyers.Insert;

      If bEditBuyer = False then
        tblBuyers['Buyers_ID'] := edtBuyer_ID.Text;

      tblBuyers['Buyers_Name'] := edtName.Text;
      tblBuyers['Buyers_Surname'] := edtSurname.Text;
      tblBuyers['Buyers_Cell_Number'] := edtContactNumber.Text;
      tblBuyers['Buyers_Email'] := edtEmail.Text;
      tblBuyers.Post;
    end;
    If bEditBuyer = False then
      ShowMessage('Buyer was added successfully.')
    else
      ShowMessage('Buyers was edited successfully.')
  end;
  bEditBuyer := False;
end;

procedure TfrmAuction2.btnBackClick(Sender: TObject);
begin
  frmLogin.Logout;
  frmAuctions.show;
  frmAuction2.Hide;
end;

procedure TfrmAuction2.btnBuy_ID_SearchClick(Sender: TObject);
var
  sBuyerID: String;
  bFound: Boolean;
begin
  // Search for buyer ID, if found then load
  sBuyerID := edtBuy_ID_Search.Text;
  If (frmAuctions.ID_LengthCheck(sBuyerID) = False) then
  begin
    ShowMessage('Please make sure the buyer ID is the correct length');
    Exit;
  end;
  If (frmAuctions.ID_OnlyNumCheck(sBuyerID) = False) then
  begin
    ShowMessage('Please make sure the buyer ID consists of numbers only.');
    Exit;
  end;
  begin
    bFound := False;
    With dmPAT_DB do
    begin
      tblBuyers.First;
      While NOT(tblBuyers.Eof) AND (bFound = True) do
      begin
        If tblBuyers['Buyers_ID'] = sBuyerID then
          bFound := True;
        LoadBuyerInfo
      end;
    end;

    If (bFound = False) then
      ShowMessage('Seller ID not found.')
  end;
end;

procedure TfrmAuction2.btnLogoutClick(Sender: TObject);
begin
  frmLogin.Logout;
  frmLogin.show;
  frmAuction2.Close;
end;

procedure TfrmAuction2.btnSaveClick(Sender: TObject);
var
  sName, sSurname, sCellnumber, sID, sEmail: string;
begin

  sName := edtName.Text;
  sSurname := edtSurname.Text;
  sCellnumber := edtContactNumber.Text;
  sID := edtBuyer_ID.Text;
  sEmail := edtEmail.Text;

  If (chkAccept_Terms.Checked = False) then
  begin
    ShowMessage('The buyer must accept the terms and conditions to proceed.');
    Exit;
  end;

  If frmReception.ValidateSellerInfo(sName, sSurname, sCellnumber, sID, sEmail)
    = False then
    Exit;

  If dmPAT_DB.tblBuyers.Locate('Buyers_ID', edtBuyer_ID.Text, []) = True then
  begin
    if (MessageDlg
      ('A buyer already exists with this ID number, do you wish to update it with the current information?',
      mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes) then
      bEditBuyer := True
    else
      Exit;
  end;

  AddBuyer;
end;

procedure TfrmAuction2.btnSoldClick(Sender: TObject);
begin
  With dmPAT_DB do
  begin
    tblAuctions.Edit;
    tblAuctions['Winning_Bid'] := cCurrentBid;
    IF tblAuctions['DateTime_Auctioned'] < Now() then
      tblAuctions['Status'] := 'Completed';
    tblAuctions.Post;

    tblProperties.Edit;
    tblProperties['Reserve_Price'] := strtoint(edtReservePrice.Text);
    tblProperties['Starting_Bid'] := strtoint(edtStartingBid.Text);
    tblProperties.Post;
  end;
  ShowMessage('Auction was successfully saved.');
end;

procedure TfrmAuction2.FormActivate(Sender: TObject);
begin
  If dmPAT_DB.tblProperties['Starting_Bid'] = NULL then
    edtStartingBid.Text := '0'
  else
    edtStartingBid.Text := dmPAT_DB.tblProperties['Starting_Bid'];

  If dmPAT_DB.qryA['Status'] = 'Completed' then
  begin
    If dmPAT_DB.tblAuctions['Winning_Bid'] = NULL then
      cCurrentBid := 0
    else
      cCurrentBid := floattocurr(dmPAT_DB.tblAuctions['Winning_Bid']);

    LoadBuyerInfo;
  end
  else
    cCurrentBid := strtocurr(edtStartingBid.Text);

  edtCurrentBid.Text := currtostr(cCurrentBid);

  If dmPAT_DB.tblProperties['Reserve_Price'] = NULL then
    edtReservePrice.Text := '0'
  else
    edtReservePrice.Text := dmPAT_DB.tblProperties['Reserve_Price'];

  PropertyDescription;
end;

procedure TfrmAuction2.img1stBidDecClick(Sender: TObject);
var
  cCurrentBidtemp: Currency;
begin
  cCurrentBidtemp := cCurrentBid - 10000;
  If ((cCurrentBidtemp) < strtocurr(edtReservePrice.Text)) then
    ShowMessage('A bid cannot be less than the reserve price')
  else
  begin
    edtCurrentBid.Text := Format('%m', [cCurrentBidtemp]);
    cCurrentBid := cCurrentBidtemp;
  end;
end;

procedure TfrmAuction2.img1stBidIncClick(Sender: TObject);
begin
  cCurrentBid := cCurrentBid + 10000;
  edtCurrentBid.Text := Format('%m', [cCurrentBid]);
end;

procedure TfrmAuction2.img2ndBidDecClick(Sender: TObject);
var
  cCurrentBidtemp: Currency;
begin
  cCurrentBidtemp := cCurrentBid - 50000;
  If ((cCurrentBidtemp) < strtocurr(edtReservePrice.Text)) then
    ShowMessage('A bid cannot be less than the reserve price')
  else
  begin
    edtCurrentBid.Text := Format('%m', [cCurrentBidtemp]);
    cCurrentBid := cCurrentBidtemp;
  end;
end;

procedure TfrmAuction2.img2ndBidIncClick(Sender: TObject);
begin
  cCurrentBid := cCurrentBid + 50000;
  edtCurrentBid.Text := Format('%m', [cCurrentBid]);;
end;

procedure TfrmAuction2.img3rdBidDecClick(Sender: TObject);
var
  cCurrentBidtemp: Currency;
begin
  cCurrentBidtemp := cCurrentBid - 100000;
  If ((cCurrentBidtemp) < strtocurr(edtReservePrice.Text)) then
    ShowMessage('A bid cannot be less than the reserve price')
  else
  begin
    edtCurrentBid.Text := Format('%m', [cCurrentBidtemp]);
    cCurrentBid := cCurrentBidtemp;
  end;
end;

procedure TfrmAuction2.img3rdBidIncClick(Sender: TObject);
begin
  cCurrentBid := cCurrentBid + 100000;
  edtCurrentBid.Text := Format('%m', [cCurrentBid]);
end;

procedure TfrmAuction2.LoadBuyerInfo;
begin
  edtName.Text := dmPAT_DB.tblBuyers['Buyers_Name'];
  edtSurname.Text := dmPAT_DB.tblBuyers['Buyers_Surname'];
  edtEmail.Text := dmPAT_DB.tblBuyers['Buyers_Email'];
  edtContactNumber.Text := dmPAT_DB.tblBuyers['Buyers_Cell_Number'];
  edtBuyer_ID.Text := dmPAT_DB.tblBuyers['Buyers_ID'];
  chkAccept_Terms.Checked := True;
end;

procedure TfrmAuction2.PropertyDescription;
begin
  lblLocation.Caption := dmPAT_DB.tblProperties['Address'];
  lblType.Caption := dmPAT_DB.tblProperties['Property_Type'];
  lblSquareFootage.Caption :=
    inttostr(dmPAT_DB.tblProperties['Square_Footage']);

  lblBedrooms.Caption := inttostr(dmPAT_DB.tblProperties['Bedrooms']);
  lblBathrooms.Caption := inttostr(dmPAT_DB.tblProperties['Bathrooms']);
  lblGarages.Caption := inttostr(dmPAT_DB.tblProperties['Garages']);
end;

end.
