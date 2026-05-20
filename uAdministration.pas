unit uAdministration;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Math;

type
  TfrmAdministration = class(TForm)
    imgAdministration: TImage;
    lblAdministration: TLabel;
    imgAuctions: TImage;
    lblUserLog: TLabel;
    btnLogout: TButton;
    grpUserInfo: TGroupBox;
    lblName: TLabel;
    lblContactNumber: TLabel;
    lblBuyer_ID: TLabel;
    lblSurname: TLabel;
    edtContactNumber: TEdit;
    edtSurname: TEdit;
    edtUser_ID: TEdit;
    edtName: TEdit;
    btnSave: TButton;
    lblPassword: TLabel;
    lblUsername: TLabel;
    edtUsername: TEdit;
    edtPassword: TEdit;
    lblJobPosition: TLabel;
    cmbJobPosition: TComboBox;
    gpbUserControls: TGroupBox;
    lblCurrentUser: TLabel;
    btnEdit: TButton;
    btnLast: TButton;
    btnFirst: TButton;
    bitbtnPrevious: TBitBtn;
    bitbtnNext: TBitBtn;
    bitbtn2Previous: TBitBtn;
    bitbtn2Next: TBitBtn;
    edtUser_ID_Search: TEdit;
    btnSearch: TButton;
    btnInsert: TButton;
    btnResetSearch: TButton;
    btnClearUserLog: TButton;
    btnDelete: TButton;
    procedure btnLogoutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure btnFirstClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btnChangeCredencialsClick(Sender: TObject);
    procedure edtUser_ID_SearchEnter(Sender: TObject);
    procedure bitbtnNextClick(Sender: TObject);
    procedure bitbtnPreviousClick(Sender: TObject);
    procedure bitbtn2NextClick(Sender: TObject);
    procedure bitbtn2PreviousClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnResetSearchClick(Sender: TObject);
    procedure btnClearUserLogClick(Sender: TObject);
  private
    { Private declarations }
    procedure LoadUserInfo;
    procedure LoadCredencials;
    procedure SetLblCurrentUser(iRecordChange: Integer);
    procedure PopulateJobPosition;
    procedure SaveUserInfo;
    function ValidateUserInfo: Boolean;
    procedure ResetUserInfo;
    procedure ResetQuery;
  public
    { Public declarations }
    function Encrypt(sEncryptLine: String): String;
    function Decrypt(sDecryptLine: String): String;
  end;

var
  frmAdministration: TfrmAdministration;

implementation

{$R *.dfm}

Uses
  uLogin, dmPAT_DB_U, uAuctions, Users_u;

var
  iNumRecord: Integer;
  iCurrentRecord: Integer;
  sName, sSurname, sCellNumber, sJobPosition, sID, sUsername, sPassword,
    sID_Old: String;
  bInsert: Boolean;

procedure TfrmAdministration.bitbtn2NextClick(Sender: TObject);
begin
  SetLblCurrentUser(5);
  LoadUserInfo;
  LoadCredencials;
end;

procedure TfrmAdministration.bitbtn2PreviousClick(Sender: TObject);
begin
  SetLblCurrentUser(-5);
  LoadUserInfo;
  LoadCredencials;
end;

procedure TfrmAdministration.bitbtnNextClick(Sender: TObject);
begin
  SetLblCurrentUser(1);
  LoadUserInfo;
  LoadCredencials;
end;

procedure TfrmAdministration.bitbtnPreviousClick(Sender: TObject);
begin
  SetLblCurrentUser(-1);
  LoadUserInfo;
  LoadCredencials;
end;

procedure TfrmAdministration.btnChangeCredencialsClick(Sender: TObject);
var
  sPassword: String;
  sUsername: String;
begin
  sUsername := edtUsername.Text;
  sPassword := edtPassword.Text;

  frmLogin.SpaceCheck(sUsername);
  frmLogin.SpaceCheck(sPassword);

  frmLogin.LengthCheck(sPassword);
  frmLogin.LengthCheck(sUsername);

end;

procedure TfrmAdministration.btnClearUserLogClick(Sender: TObject);
var
  tUsersLogin: Textfile;
begin
  AssignFile(tUsersLogin, 'Login.txt');
  Rewrite(tUsersLogin);
  CloseFile(tUsersLogin);
end;

procedure TfrmAdministration.btnDeleteClick(Sender: TObject);
var
  sSQL: string;
  iLoop: Integer;
  bFound: Boolean;
begin
  dmPAT_DB.tblUsers.Locate('Users_ID', edtUser_ID.Text, []);

  If cmbJobPosition.Items[cmbJobPosition.ItemIndex] = 'Auctioneer' then
  begin
    ShowMessage
      ('An auctioneers records cannot be erased from the database as it would delete records, their account has therefore been deactivated.');
    dmPAT_DB.tblUsers.Edit;
    dmPAT_DB.tblUsers['IsActive'] := False;
    dmPAT_DB.tblUsers.Post;
  end
  else
  begin
    sSQL := 'SELECT Job_Position ' + 'FROM tblUsers ' + 'WHERE Job_Position = "'
      + sJobPosition + '" ' + 'AND IsActive = True';
    dmPAT_DB.runSQLB(sSQL);
    If dmPAT_DB.tblUsers.RecordCount <= 1 then
    begin
      ShowMessage('At least 1 ' + sJobPosition +
        ' must be active at any time, please register a new admin if you wish to be removed from the database.');
      Exit;
    end
    else
    begin
      dmPAT_DB.tblUsers.Delete;
    end;
  end;

  iLoop := 1;
  bFound := False;
  While (iLoop <= frmLogin.iUsersCount) AND (bFound = False) do
  begin
    If (frmLogin.arrUsers[iLoop].getID = sID) then
    begin
      bFound := True;
      frmLogin.arrUsers[iLoop].setUsername(' ');
    end;
    Inc(iLoop);
  end;

  ResetQuery;

end;

procedure TfrmAdministration.btnEditClick(Sender: TObject);
begin
  grpUserInfo.Enabled := True;
  btnSave.Visible := True;
  gpbUserControls.Enabled := False;
  edtUser_ID_Search.Enabled := False;
  btnSearch.Enabled := False;
  btnResetSearch.Enabled := False;
end;

procedure TfrmAdministration.btnFirstClick(Sender: TObject);
begin
  begin
    dmPAT_DB.qryA.First;
    LoadCredencials;
    LoadUserInfo;
    iCurrentRecord := 1;
    lblCurrentUser.Caption := inttostr(iCurrentRecord) + ' / ' +
      inttostr(iNumRecord);
  end;
end;

procedure TfrmAdministration.btnInsertClick(Sender: TObject);
begin
  bInsert := True;
  gpbUserControls.Visible := False;
  grpUserInfo.Enabled := True;
  btnSave.Show;
  ResetUserInfo;
end;

procedure TfrmAdministration.btnLastClick(Sender: TObject);
begin
  dmPAT_DB.qryA.Last;
  LoadCredencials;
  LoadUserInfo;
  iCurrentRecord := iNumRecord;
  lblCurrentUser.Caption := inttostr(iCurrentRecord) + ' / ' +
    inttostr(iNumRecord);
end;

procedure TfrmAdministration.btnLogoutClick(Sender: TObject);
var
  iCount: Integer;
  tUsersLogin: Textfile;
begin
  If bInsert = True then
  begin
    edtUser_ID_Search.Show;
    btnSearch.Show;
    cmbJobPosition.Text := '';
    gpbUserControls.Show;
  end;

  frmLogin.Logout;

  AssignFile(tUsersLogin, 'Login.txt');
  Rewrite(tUsersLogin);

  For iCount := 1 to (frmLogin.iUsersCount) do
  begin
    if (frmLogin.arrUsers[iCount].getUsername <> ' ') then
      Writeln(tUsersLogin, Encrypt(frmLogin.arrUsers[iCount].getUsername + '#' +
        frmLogin.arrUsers[iCount].getPassword + '#' + frmLogin.arrUsers
        [iCount].getID));
  end;
  CloseFile(tUsersLogin);

  frmLogin.Show;
  frmAdministration.Hide;
end;

procedure TfrmAdministration.btnNextClick(Sender: TObject);
begin
  dmPAT_DB.tblUsers.Next;
  LoadCredencials;
end;

procedure TfrmAdministration.btnPreviousClick(Sender: TObject);
begin
  dmPAT_DB.tblUsers.Prior;
  LoadCredencials;
end;

procedure TfrmAdministration.btnResetSearchClick(Sender: TObject);
var
  sSQL: string;
begin
  sSQL := 'SELECT *' + ' FROM tblUsers' + ' WHERE IsActive = True';
  dmPAT_DB.runSQL(sSQL);
  iNumRecord := dmPAT_DB.qryA.RecordCount;
  lblCurrentUser.Caption := '1 / ' + inttostr(iNumRecord);
  dmPAT_DB.qryA.First;
  LoadUserInfo;
  LoadCredencials;

  bInsert := False;
  gpbUserControls.Show;
end;

procedure TfrmAdministration.btnSaveClick(Sender: TObject);

begin
  sName := edtName.Text;
  sSurname := edtSurname.Text;
  sCellNumber := edtContactNumber.Text;
  sID := edtUser_ID.Text;
  sUsername := edtUsername.Text;
  sPassword := edtPassword.Text;

  If (ValidateUserInfo = False) then
    Exit;

  sJobPosition := cmbJobPosition.Items[cmbJobPosition.ItemIndex];

  SaveUserInfo;

  grpUserInfo.Enabled := False;
  btnSave.Visible := False;
  gpbUserControls.Enabled := True;
  edtUser_ID_Search.Visible := True;
  btnSearch.Visible := True;
  btnResetSearch.Enabled := True;

  ResetQuery;
end;

procedure TfrmAdministration.btnSearchClick(Sender: TObject);
var
  sID_Search: string;
  bFound: Boolean;
  iCount: Integer;
begin
  sID_Search := edtUser_ID_Search.Text;

  If (frmAuctions.ID_LengthCheck(sID_Search) = False) then
  begin
    ShowMessage('The searching user ID is not the correct length.');
    Exit;
  end
  else If (frmAuctions.ID_OnlyNumCheck(sID_Search) = False) then
  begin
    ShowMessage('The searching user ID must have integers only.');
    Exit;
  end;

  bFound := False;
  // Used to make the label in correct pos (only occurs in 1st search)
  iCount := 1;
  While (bFound = False) AND (iCount <= (iNumRecord)) do
  begin
    If (dmPAT_DB.qryA['Users_ID'] = sID_Search) then
      bFound := True
    else
    begin
      SetLblCurrentUser(1);
      Inc(iCount);
    end;
  end;

  If (bFound = False) then
    ShowMessage('User ID was not found.');

  LoadUserInfo;

end;

function TfrmAdministration.Decrypt(sDecryptLine: String): String;
var
  iLoop: Integer;
begin
  Result := '';
  For iLoop := 1 to Length(sDecryptLine) do
  begin
    Result := Result + Char((Ord(sDecryptLine[iLoop]) - 8));;
  end;
end;

procedure TfrmAdministration.ResetQuery;
var
  sSQL: string;
begin
  sSQL := 'SELECT *' + ' FROM tblUsers' + ' WHERE IsActive = True';
  dmPAT_DB.runSQL(sSQL);
  dmPAT_DB.qryA.First;
  iNumRecord := dmPAT_DB.qryA.RecordCount;
  lblCurrentUser.Caption := '1 / ' + inttostr(iNumRecord);
  PopulateJobPosition;
  LoadUserInfo;
  LoadCredencials;
end;

procedure TfrmAdministration.edtUser_ID_SearchEnter(Sender: TObject);
begin
  edtUser_ID_Search.Hint := 'Leave blank if not included in search.';
end;

function TfrmAdministration.Encrypt(sEncryptLine: String): String;
var
  iLoop: Integer;
begin
  Result := '';
  For iLoop := 1 to Length(sEncryptLine) do
  begin
    Result := Result + Char((Ord(sEncryptLine[iLoop]) + 8));
  end;
end;

procedure TfrmAdministration.FormActivate(Sender: TObject);
var
  sLastLog: string;
begin
  sLastLog := uLogin.frmLogin.UserLog;
  If Length(sLastLog) > 0 then
    lblUserLog.Caption := uLogin.frmLogin.UserLog
  else
    lblUserLog.Visible := False;
  ResetQuery;

  bInsert := False;
  iCurrentRecord := 1;
end;

procedure TfrmAdministration.LoadCredencials;
var
  iLoop: Integer;
  bID_Found: Boolean;
  sID: String;
begin
  iLoop := 1;
  bID_Found := False;
  sID := dmPAT_DB.qryA['Users_ID'];

  While (iLoop <= (frmLogin.iUsersCount - 1)) AND (bID_Found = False) do
  begin
    If (frmLogin.arrUsers[iLoop].getID = sID) then
    Begin
      bID_Found := True;
      edtUsername.Text := frmLogin.arrUsers[iLoop].getUsername;
      edtPassword.Text := frmLogin.arrUsers[iLoop].getPassword;
    End;
    Inc(iLoop);
  end;
end;

procedure TfrmAdministration.LoadUserInfo;
var
  iLoop, iMax: Integer;
  bFound: Boolean;
begin

  edtName.Text := dmPAT_DB.qryA['Users_Name'];
  edtSurname.Text := dmPAT_DB.qryA['Users_Surname'];
  edtContactNumber.Text := dmPAT_DB.qryA['Users_Cell_Number'];
  edtUser_ID.Text := dmPAT_DB.qryA['Users_ID'];
  sID_Old := dmPAT_DB.qryA['Users_ID'];

  iLoop := 0;
  iMax := cmbJobPosition.DropDownCount;
  bFound := False;

  While (iLoop <= iMax) and (bFound = False) do
  begin
    If cmbJobPosition.Items[iLoop] = dmPAT_DB.qryA['Job_Position'] then
    begin
      cmbJobPosition.ItemIndex := iLoop;
      sJobPosition := cmbJobPosition.Items[iLoop];
      cmbJobPosition.Text := cmbJobPosition.Items[iLoop];
      bFound := True;
    end;
    Inc(iLoop);
  end;
end;

procedure TfrmAdministration.PopulateJobPosition;
var
  sSQL: String;
begin
  sSQL := 'SELECT DISTINCT Job_Position ' + 'FROM tblUsers';
  dmPAT_DB.runSQLB(sSQL);

  dmPAT_DB.qryB.First;
  While NOT(dmPAT_DB.qryB.Eof) do
  begin
    cmbJobPosition.Items.Add(dmPAT_DB.qryB['Job_Position']);
    dmPAT_DB.qryB.Next;
  end;
end;

procedure TfrmAdministration.ResetUserInfo;
begin
  edtUser_ID_Search.Hide;
  btnSearch.Hide;

  edtName.Clear;
  edtSurname.Clear;
  edtUser_ID.Clear;
  edtContactNumber.Clear;
  cmbJobPosition.Text := '';

  edtUsername.Clear;
  edtPassword.Clear;

  gpbUserControls.Hide;
end;

procedure TfrmAdministration.SaveUserInfo;
var
  iLoop: Integer;
begin
  If bInsert = True then // The admin is inserting a new user
  begin // Check if an account already exists and enables it if so.
    If dmPAT_DB.tblUsers.Locate('Users_ID', sID, []) = True then
    begin
      dmPAT_DB.tblUsers.Edit;
      dmPAT_DB.tblUsers['IsActive'] := True;
      ShowMessage
        ('An ID already exists in the database of the new user, their account is now enabled and will be updated with the new information.')
    end
    else
    begin
      dmPAT_DB.tblUsers.Insert;
      dmPAT_DB.tblUsers['IsActive'] := True;
      dmPAT_DB.tblUsers['Users_ID'] := sID;
    end;
  end
  else
  begin
    dmPAT_DB.tblUsers.Locate('Users_ID', sID, []);
    dmPAT_DB.tblUsers.Edit; // If insert is false, then it is edit mode
  end;

  // Update or insert record in users table
  dmPAT_DB.tblUsers['Users_Name'] := sName;
  dmPAT_DB.tblUsers['Users_Surname'] := sSurname;
  dmPAT_DB.tblUsers['Users_Cell_Number'] := sCellNumber;
  dmPAT_DB.tblUsers['Job_Position'] := sJobPosition;
  dmPAT_DB.tblUsers['IsActive'] := True;
  dmPAT_DB.tblUsers.Post;

  If bInsert = True then
  begin
    if (frmLogin.iUsersCount + 1) < ((High(frmLogin.arrUsers) - 1)) then
      SetLength(frmLogin.arrUsers, Length(frmLogin.arrUsers) * 2);

    Inc(frmLogin.iUsersCount);
    frmLogin.arrUsers[frmLogin.iUsersCount] :=
      Users_u.TUsers.Create(sID, sUsername, sPassword, sJobPosition);
  end
  else
  begin
    For iLoop := 1 to iNumRecord do
    begin
      If sID_Old = frmLogin.arrUsers[iLoop].getID then
      begin
        frmLogin.arrUsers[iLoop].setUsername(sUsername);
        frmLogin.arrUsers[iLoop].setPassword(sPassword);
        frmLogin.arrUsers[iLoop].setID(sID);
      end;
    end;
  end;

  if bInsert = True then
  begin
    ShowMessage('The user has been registered successfully!');
  end
  else
    ShowMessage('The user has been updated successfully!');

  bInsert := False;
  grpUserInfo.Enabled := False;
  gpbUserControls.Show;
end;

procedure TfrmAdministration.SetLblCurrentUser(iRecordChange: Integer);
var
  iRecordLoop: Integer;
begin
  If (iCurrentRecord + iRecordChange) > iNumRecord then
  begin
    dmPAT_DB.qryA.First;
    iCurrentRecord := 1;

    lblCurrentUser.Caption := '1 / ' + inttostr(iNumRecord);
  end
  else If (iCurrentRecord + iRecordChange) < 1 then
  begin
    dmPAT_DB.qryA.Last;
    iCurrentRecord := iNumRecord;

    lblCurrentUser.Caption := inttostr(iNumRecord) + ' / ' +
      inttostr(iNumRecord);
  end
  else If iRecordChange > 0 then
  begin
    For iRecordLoop := 1 to iRecordChange do
    begin
      dmPAT_DB.qryA.Next;
      Inc(iCurrentRecord);

      lblCurrentUser.Caption := inttostr(iCurrentRecord) + ' / ' +
        inttostr(iNumRecord);
    end;
  end
  else
  begin
    For iRecordLoop := 1 to (iRecordChange * -1) do
    begin
      dmPAT_DB.qryA.Prior;
      Dec(iCurrentRecord);

      lblCurrentUser.Caption := inttostr(iCurrentRecord) + ' / ' +
        inttostr(iNumRecord);
    end;
  end;
end;

function TfrmAdministration.ValidateUserInfo: Boolean;
begin
  Result := True; // Validates user info
  If (Length(sName) < 1) then
  begin
    ShowMessage('Please make sure the users name is at least 1 letter long.');
    Result := False;
    Exit
  end
  else If (Pos(' ', sName) > 0) then
  begin
    ShowMessage('Please make sure the users name has no spaces in it.');
    Result := False;
    Exit
  end
  else If (Length(sSurname) = 0) then
  begin
    ShowMessage
      ('Please make sure the users surname is at least 1 letter long.');
    Result := False;
    Exit
  end
  else If (frmAuctions.ID_LengthCheck(sID) = False) then
  begin
    ShowMessage('Please make sure the seller ID is 13 digits long.');
    Result := False;
    Exit
  end
  else If (frmAuctions.ID_OnlyNumCheck(sID) = False) then
  begin
    ShowMessage('Please make sure the seller ID only consists of numbers.');
    Result := False;
    Exit
  end
  else If (Length(sCellNumber) <> 10) then
  begin
    ShowMessage('Please make sure the users contact number is 10 digits long.');
    Result := False;
    Exit
  end
  else If (sCellNumber[1] <> '0') then
  begin
    ShowMessage('Please make sure the users contact number starts with a "0".');
    Result := False;
    Exit
  end
  else If (cmbJobPosition.ItemIndex < 0) then
  begin
    ShowMessage
      ('Please make sure you have selected the new users job position.');
    Result := False;
    Exit
  end
  else If frmLogin.SpaceCheck(sUsername) = False then
  begin
    Result := False;
    Exit
  end
  else If frmLogin.SpaceCheck(sPassword) = False then
  begin
    Result := False;
    Exit
  end
  else If frmLogin.LengthCheck(sUsername) = False then
  begin
    Result := False;
    Exit
  end
  else If frmLogin.LengthCheck(sPassword) = False then
  begin
    Result := False;
    Exit
  end
  else If (Pos('#', sUsername) > 0) then
  begin
    ShowMessage
      ('Please make sure the username and password has hashtags("#") in it.');
    Result := False;
    Exit
  end
  else If (Pos('#', sPassword) > 0) then
  begin
    ShowMessage
      ('Please make sure the username and password has hashtags("#") in it.');
    Result := False;
    Exit
  end
end;

end.
