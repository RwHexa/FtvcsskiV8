
unit Unit1;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.StdCtrls, WEBLib.StdCtrls, WEBLib.JSON, Types,
  Vcl.Grids, WEBLib.Grids, WEBLib.WebCtrls, WEBLib.WebTools;

type
  TTeam = record
    Name: string;
    Points, GoalsFor, GoalsAgainst, Played: Integer;
  end;

type
  TForm1 = class(TWebForm)
    // Hauptstruktur-Container
    divAnwenderWrapper: TWebHTMLDiv;
    divStartseite: TWebHTMLDiv;
    divAnwenderCard: TWebHTMLDiv;
    
    // Startseite Controls
    btnZurAnwend: TWebButton;
    
    // Anwender-Seite Controls (Ftmanager)
    btnZurStartseite: TWebButton;
    
    // Ftmanager Controls in der Card
    edtTeamName: TWebEdit;
    btnAddTeam: TWebButton;
    cmbTeam1: TWebComboBox;
    cmbTeam2: TWebComboBox;
    edtGoals1: TWebEdit;
    edtGoals2: TWebEdit;
    btnAddResult: TWebButton;
    gridTable: TWebStringGrid;
    gridResults: TWebStringGrid;
    laden: TWebButton;
    speichern: TWebButton;
    WebLabel3: TWebLabel;
    WebLabel4: TWebLabel;
    WebImageControl1: TWebImageControl;
    WebLabel1: TWebLabel;
    WebLabel5: TWebLabel;
    WebButton1: TWebButton;
    WebLabel6: TWebLabel;

    procedure WebFormCreate(Sender: TObject);
    procedure btnZurStartseiteClick(Sender: TObject);
    procedure btnZurAnwendClick(Sender: TObject);
    procedure btnAddTeamClick(Sender: TObject);
    procedure btnAddResultClick(Sender: TObject);
    procedure ladenClick(Sender: TObject);
    procedure speichernClick(Sender: TObject);
    procedure WebFormResize(Sender: TObject);
  private
    { Private-Deklarationen }
    FTeams: array[0..5] of TTeam;
    FTeamCount: Integer;
    procedure InitializeTable;
    procedure InitializeResultsGrid;
    procedure UpdateTeamList;
    procedure UpdateTable;
    procedure AddMatchResult(const HomeTeam, AwayTeam: string; HomeGoals, AwayGoals: Integer);
    procedure SetupFtmanagerControls;
     procedure ResetRowColors;    // <- NEU HINZUFÜGEN
     procedure FixRowColors;      // <- NEU HINZUFÜGEN
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnZurAnwendClick(Sender: TObject);
begin
  // Verstecke die Startseite
  divStartseite.ElementHandle.classList.add('hidden');
  
  // Zeige die Anwenderseite
  divAnwenderWrapper.ElementHandle.classList.remove('hidden');
  
  // Setup Ftmanager Controls
  SetupFtmanagerControls;
end;

procedure TForm1.btnZurStartseiteClick(Sender: TObject);
begin
  // Verstecke die Anwenderseite
  divAnwenderWrapper.ElementHandle.classList.add('hidden');
  
  // Zeige die Startseite
  divStartseite.ElementHandle.classList.remove('hidden');
end;

procedure TForm1.WebFormCreate(Sender: TObject);
begin
  inherited;

  // ===== CARD-STRUKTUR SETUP =====
  divStartseite.ElementClassName      := 'fullscreen-container start-seite';
  divAnwenderWrapper.ElementClassName := 'fullscreen-container wrapper';
  divAnwenderCard.ElementClassName    := 'card';

  btnZurAnwend.ElementClassName := 'nav-button-top';
  WebImageControl1.ElementClassName := 'poster-image';

  // ===== NAVIGATION INITIAL STATE =====
  divStartseite.ElementHandle.classList.remove('hidden');
  divAnwenderWrapper.ElementHandle.classList.add('hidden');

  // ===== FTMANAGER INITIALISIERUNG =====
  FTeamCount := 0;
  InitializeTable;
  InitializeResultsGrid;
  
  // Eingabefelder initialisieren
  edtTeamName.Text := '  teiln. Mannschaften';

   // Tor-Eingabefelder größer und zentriert
  edtGoals1.Text := '0';
  edtGoals2.Text := '0';

  // Größere und zentrierte Tor-Eingabe
  edtGoals1.Font.Size := 18;  // Größere Schrift
  edtGoals2.Font.Size := 18;
  edtGoals1.Height := 40;     // Höher
  edtGoals2.Height := 40;
  edtGoals1.Width := 45;      // Etwas breiter
  edtGoals2.Width := 45;

  // Zentrierung und Styling
  edtGoals1.ElementHandle.style.setProperty('text-align', 'center');
  edtGoals2.ElementHandle.style.setProperty('text-align', 'center');
  edtGoals1.ElementHandle.style.setProperty('font-weight', 'bold');
  edtGoals2.ElementHandle.style.setProperty('font-weight', 'bold');
  edtGoals1.ElementHandle.style.setProperty('border', '2px solid #007acc');
  edtGoals2.ElementHandle.style.setProperty('border', '2px solid #007acc');
  edtGoals1.ElementHandle.style.setProperty('border-radius', '6px');
  edtGoals2.ElementHandle.style.setProperty('border-radius', '6px');

  //edtGoals1.Text := '0';
  //edtGoals2.Text := '0';
 // edtGoals1.ElementHandle.style.setProperty('text-align', 'center');
 // edtGoals2.ElementHandle.style.setProperty('text-align', 'center');

  // ComboBoxen formatieren
  cmbTeam1.Font.Size := 14;
  cmbTeam2.Font.Size := 14;
  cmbTeam1.Height := 35;
  cmbTeam2.Height := 35;
  cmbTeam1.ElementHandle.style.setProperty('padding', '4px');
  cmbTeam2.ElementHandle.style.setProperty('padding', '4px');
  
  // Eingabefelder initial deaktivieren
  cmbTeam1.Enabled := False;
  cmbTeam2.Enabled := False;
  edtGoals1.Enabled := False;
  edtGoals2.Enabled := False;
  btnAddResult.Enabled := False;
end;

procedure TForm1.WebFormResize(Sender: TObject);
begin
  // Responsive Anpassungen falls nötig
  console.log('WebFormResize called');
end;

procedure TForm1.SetupFtmanagerControls;
begin
  // Zusätzliche Setup-Logik für Ftmanager Controls in der Card
  // Hier können Sie spezielle Anpassungen für das Card-Layout vornehmen
end;

// ===== FTMANAGER FUNKTIONALITÄT =====

procedure TForm1.btnAddTeamClick(Sender: TObject);
var
  i: Integer;
begin
  if (FTeamCount >= 6) then
  begin
    ShowMessage('Maximale Anzahl von Teams (6) erreicht');
    Exit;
  end;

  if Trim(edtTeamName.Text) = '' then
  begin
    ShowMessage('Bitte Teamnamen eingeben');
    Exit;
  end;

  // Prüfe ob Team bereits existiert
  for i := 0 to FTeamCount - 1 do
    if CompareText(FTeams[i].Name, edtTeamName.Text) = 0 then
    begin
      ShowMessage('Team existiert bereits');
      Exit;
    end;

  // Füge neues Team hinzu
  FTeams[FTeamCount].Name := edtTeamName.Text;
  FTeams[FTeamCount].Points := 0;
  FTeams[FTeamCount].GoalsFor := 0;
  FTeams[FTeamCount].GoalsAgainst := 0;
  FTeams[FTeamCount].Played := 0;
  Inc(FTeamCount);

  // Aktualisiere UI
  edtTeamName.Text := '';
  UpdateTeamList;
  UpdateTable;

  // Aktiviere Ergebniseingabe wenn mind. 2 Teams vorhanden
  if FTeamCount >= 2 then
  begin
    cmbTeam1.Enabled := True;
    cmbTeam2.Enabled := True;
    edtGoals1.Enabled := True;
    edtGoals2.Enabled := True;
    btnAddResult.Enabled := True;
  end;
end;

procedure TForm1.btnAddResultClick(Sender: TObject);
var
  idx1, idx2, g1, g2: Integer;
begin
  // Prüfe Teamauswahl
  if (cmbTeam1.ItemIndex < 0) or (cmbTeam2.ItemIndex < 0) then
  begin
    ShowMessage('Bitte beide Teams auswählen');
    Exit;
  end;

  if cmbTeam1.ItemIndex = cmbTeam2.ItemIndex then
  begin
    ShowMessage('Bitte zwei verschiedene Teams auswählen');
    Exit;
  end;

  // Prüfe Toreingabe
  if not TryStrToInt(edtGoals1.Text, g1) or not TryStrToInt(edtGoals2.Text, g2) then
  begin
    ShowMessage('Bitte gültige Zahlen für Tore eingeben');
    Exit;
  end;

  idx1 := cmbTeam1.ItemIndex;
  idx2 := cmbTeam2.ItemIndex;

  // Tore eintragen
  Inc(FTeams[idx1].GoalsFor, g1);
  Inc(FTeams[idx1].GoalsAgainst, g2);
  Inc(FTeams[idx2].GoalsFor, g2);
  Inc(FTeams[idx2].GoalsAgainst, g1);

  // Punkte vergeben
  if g1 > g2 then
    Inc(FTeams[idx1].Points, 3)
  else if g1 < g2 then
    Inc(FTeams[idx2].Points, 3)
  else
  begin
    Inc(FTeams[idx1].Points);
    Inc(FTeams[idx2].Points);
  end;

  // Spiele zählen
  Inc(FTeams[idx1].Played);
  Inc(FTeams[idx2].Played);

  // Ergebnis zur Liste hinzufügen
  AddMatchResult(cmbTeam1.Text, cmbTeam2.Text, g1, g2);

  // UI zurücksetzen
  cmbTeam1.ItemIndex := -1;
  cmbTeam2.ItemIndex := -1;
  edtGoals1.Text := '0';
  edtGoals2.Text := '0';

  UpdateTable;
end;

procedure TForm1.AddMatchResult(const HomeTeam, AwayTeam: string; HomeGoals, AwayGoals: Integer);
var
  RowIndex: Integer;
begin
  // Neue Zeile hinzufügen
  RowIndex := gridResults.RowCount;
  gridResults.RowCount := RowIndex + 1;

  // Ergebnis eintragen
  gridResults.Cells[0, RowIndex] := '  ' + HomeTeam;
  gridResults.Cells[1, RowIndex] := Format('  %d:%d  ', [HomeGoals, AwayGoals]);
  gridResults.Cells[2, RowIndex] := '  ' + AwayTeam;
end;

procedure TForm1.UpdateTeamList;
var
  i: Integer;
begin
  // Aktualisiere Teamauswahl
  cmbTeam1.Items.Clear;
  cmbTeam2.Items.Clear;
  for i := 0 to FTeamCount - 1 do
  begin
    cmbTeam1.Items.Add(FTeams[i].Name);
    cmbTeam2.Items.Add(FTeams[i].Name);
  end;
end;

procedure TForm1.InitializeTable;
begin
  // Tabelle initialisieren
  gridTable.ColCount := 6;
  gridTable.DefaultRowHeight := 32;  // Erhöht für größere Schrift

  // Tabelle verbreitern - passt zu Ihrem Layout (die gridResults ist bei Left=360)
  gridTable.Width := 435;  // Verbreitert von 320 auf 420

  // Spaltenbreiten optimiert für die neue Breite
  gridTable.ColWidths[0] := 160;      // Mannschaft (Vereine)
  gridTable.ColWidths[1] := 45;       // Spiele
  gridTable.ColWidths[2] := 85;       // Tore (breiter für "12:34" Format)
  gridTable.ColWidths[3] := 50;       // Differenz
  gridTable.ColWidths[4] := 45;       // Punkte
  gridTable.ColWidths[5] := 35;       // Platz

  // Überschriften
  gridTable.Cells[0, 0] := 'Vereine';
  gridTable.Cells[1, 0] := 'Sp.';
  gridTable.Cells[2, 0] := 'Tore';
  gridTable.Cells[3, 0] := 'Diff.';
  gridTable.Cells[4, 0] := 'Pkt.';
  gridTable.Cells[5, 0] := 'Pl.';

  // Formatierung - Schrift vergrößert und zentriert
  gridTable.Color := clWhite;
  //gridTable.FixedColor := RGB(255,255,0);
  gridTable.Font.Name := 'Segoe UI';
  gridTable.Font.Size := 13;  // Vergrößert von 12 auf 13 (nicht zu groß für das Layout)
  gridTable.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect];
  gridTable.RowHeights[0] := 28;  // Kopfzeile etwas höher

  // Zentrierung über CSS
  gridTable.ElementHandle.style.setProperty('text-align', 'center');

  // Zusätzliche Formatierung für bessere Optik
  gridTable.ElementHandle.style.setProperty('border', '1px solid #ccc');
  gridTable.ElementHandle.style.setProperty('border-radius', '4px');

  gridTable.ElementClassName := 'table-striped';
end;

procedure TForm1.ResetRowColors;
 var
  i: Integer;
begin
  // Alle Zeilen explizit auf einheitliche Höhe setzen
  for i := 1 to gridTable.RowCount - 1 do
  begin
    gridTable.RowHeights[i] := 32; // Einheitliche Höhe
  end;
end;

procedure TForm1.FixRowColors;
var
  i: Integer;
begin
  gridTable.Color := clWhite;
  gridTable.ElementHandle.style.setProperty('background-color', 'white');
end;

procedure TForm1.InitializeResultsGrid;
begin

  // WICHTIG: Erst die Row-Einstellungen korrigieren
  gridResults.RowCount := 1;        // Nur eine Zeile initial
  gridResults.FixedRows := 0;       // KEINE festen Header-Zeilen!
  gridResults.FixedCols := 0;       // Keine festen Spalten

  // Spaltenbreiten
  gridResults.ColWidths[0] := 120;   // Heimmannschaft
  gridResults.ColWidths[1] := 50;    // Ergebnis
  gridResults.ColWidths[2] := 120;   // Gastmannschaft

  // Grundformatierung
  gridResults.Font.Name := 'Segoe UI';
  gridResults.Font.Size := 14;
  gridResults.DefaultRowHeight := 24;
  gridResults.Color := clWhite;

  // CSS-Klasse zuweisen (falls Sie die CSS-Lösung verwenden)
  gridResults.ElementClassName := 'results-grid';

  // ODER einfaches Styling ohne CSS-Klasse:
  //gridResults.ElementHandle.style.setProperty('border', '1px solid #ddd');
  //gridResults.ElementHandle.style.setProperty('border-radius', '6px');
  //gridResults.ElementHandle.style.setProperty('background-color', '#fafafa');

end;



procedure TForm1.UpdateTable;
var
  i: Integer;
  SortedTeams: TArray<TTeam>;
  Diff: Integer;
  
  procedure SortTeams;
  var
    i, j: Integer;
    temp: TTeam;
  begin
    for i := Low(SortedTeams) to High(SortedTeams) - 1 do
      for j := i + 1 to High(SortedTeams) do
        if (SortedTeams[j].Points > SortedTeams[i].Points) or
           ((SortedTeams[j].Points = SortedTeams[i].Points) and
            ((SortedTeams[j].GoalsFor - SortedTeams[j].GoalsAgainst) >
             (SortedTeams[i].GoalsFor - SortedTeams[i].GoalsAgainst))) then
        begin
          temp := SortedTeams[i];
          SortedTeams[i] := SortedTeams[j];
          SortedTeams[j] := temp;
        end;
  end;

begin
  if FTeamCount = 0 then
  begin
    gridTable.RowCount := 1;
    Exit;
  end;

  // Teams sortieren
  SetLength(SortedTeams, FTeamCount);
  for i := 0 to FTeamCount - 1 do
    SortedTeams[i] := FTeams[i];
  SortTeams;

  // Tabelle aktualisieren
  gridTable.RowCount := FTeamCount + 1;
  for i := 0 to FTeamCount - 1 do
  begin
    Diff := SortedTeams[i].GoalsFor - SortedTeams[i].GoalsAgainst;

    gridTable.Cells[0, i + 1] := SortedTeams[i].Name;
    gridTable.Cells[1, i + 1] := IntToStr(SortedTeams[i].Played);
    gridTable.Cells[2, i + 1] := Format('%d:%d', [SortedTeams[i].GoalsFor, SortedTeams[i].GoalsAgainst]);
    gridTable.Cells[3, i + 1] := IntToStr(Diff);
    gridTable.Cells[4, i + 1] := IntToStr(SortedTeams[i].Points);
    gridTable.Cells[5, i + 1] := IntToStr(i + 1);
  end;

      // NACH dem Update Farben korrigieren
  //FixRowColors;

end;

procedure TForm1.speichernClick(Sender: TObject);
var
  TeamData: TJSONArray;
  TeamObj: TJSONObject;
  i: Integer;
begin
  TeamData := TJSONArray.Create;
  try
    // Alle Teams in JSON-Array konvertieren
    for i := 0 to FTeamCount - 1 do
    begin
      TeamObj := TJSONObject.Create;
      TeamObj.AddPair('name', FTeams[i].Name);
      TeamObj.AddPair('points', TJSONNumber.Create(FTeams[i].Points));
      TeamObj.AddPair('goalsFor', TJSONNumber.Create(FTeams[i].GoalsFor));
      TeamObj.AddPair('goalsAgainst', TJSONNumber.Create(FTeams[i].GoalsAgainst));
      TeamObj.AddPair('played', TJSONNumber.Create(FTeams[i].Played));
      TeamData.Add(TeamObj);
    end;

    // In localStorage speichern (funktioniert in TMS Web Core)
    window.localStorage.setItem('tournamentData', TeamData.ToString);
    ShowMessage('Turnierdaten wurden gespeichert');
  finally
    TeamData.Free;
  end;
end;

procedure TForm1.ladenClick(Sender: TObject);
var
  StoredData: string;
  TeamData: TJSONArray;
  TeamObj: TJSONObject;
  i: Integer;
begin
  StoredData := window.localStorage.getItem('tournamentData');
  if StoredData = '' then
  begin
    ShowMessage('Keine gespeicherten Daten gefunden');
    Exit;
  end;

  try
    // JSON parsen
    TeamData := TJSONObject.ParseJSONValue(StoredData) as TJSONArray;
    if not Assigned(TeamData) then Exit;

    try
      // Bestehende Daten löschen
      FTeamCount := 0;

      // Daten aus JSON laden
      for i := 0 to TeamData.Count - 1 do
      begin
        TeamObj := TeamData.Items[i] as TJSONObject;

        FTeams[i].Name := TeamObj.GetValue('name').Value;
        FTeams[i].Points := (TeamObj.GetValue('points') as TJSONNumber).AsInt;
        FTeams[i].GoalsFor := (TeamObj.GetValue('goalsFor') as TJSONNumber).AsInt;
        FTeams[i].GoalsAgainst := (TeamObj.GetValue('goalsAgainst') as TJSONNumber).AsInt;
        FTeams[i].Played := (TeamObj.GetValue('played') as TJSONNumber).AsInt;
        Inc(FTeamCount);
      end;

      // UI aktualisieren
      UpdateTeamList;
      UpdateTable;

      // Eingabefelder aktivieren wenn Teams vorhanden
      if FTeamCount >= 2 then
      begin
        cmbTeam1.Enabled := True;
        cmbTeam2.Enabled := True;
        edtGoals1.Enabled := True;
        edtGoals2.Enabled := True;
        btnAddResult.Enabled := True;
      end;

      ShowMessage('Turnierdaten wurden geladen');
    finally
      TeamData.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Fehler beim Laden der Daten: ' + E.Message);
  end;
end;

end.