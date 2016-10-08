#!/usr/bin/perl -w 
use strict; 
use warnings; 
use diagnostics; 
use Tkx;
use utf8 ;
use DBI;
use DBD::SQLite;
use Encode;
use Win32::Clipboard;
use v5.14;

#SQL=#  opendb "E:\bible\bible.db"
my $dbargs = { AutoCommit => 0, PrintError => 1 };
my $dbh =
      DBI->connect("dbi:SQLite:dbname=bible.db", "", "", $dbargs)
      or die $DBI::errstr;
      
# GUI Components Declaration 
 my $mw=Tkx::widget->new("."); 
my $label1=$mw->new_ttk__label(-text=>"圣经书名");
my $bookName;
my $entry1=$mw->new_ttk__entry(-textvariable=>\$bookName);
my $combobox1_vs=join(" ",(
            "------旧约------ ",
            "以斯帖记**斯  ",
            "以斯拉记**拉  ",
            "以西结书**结  ",
            "以赛亚书**赛  ",
            "传道书**传   ",
            "但以理书**但  ",
            "何西阿书**何  ",
            "俄巴底亚书**俄 ",
            "出埃及记**出  ",
            "列王纪上**王上 ",
            "列王纪下**王下 ",
            "创世纪**创   ",
            "利未记**利   ",
            "历代志上**代上 ",
            "历代志下**代下 ",
            "哈巴谷书**哈  ",
            "哈该书**该   ",
            "士师记**士   ",
            "尼希米记**尼  ",
            "弥迦书**弥   ",
            "撒母耳记上**撒上",
            "撒母耳记下**撒下",
            "撒迦利亚书**亚 ",
            "民数记**民   ",
            "玛拉基书**玛  ",
            "申命记**申   ",
            "箴言**箴",
            "约书亚记**书  ",
            "约伯记**伯   ",
            "约拿书**拿   ",
            "约珥书**珥   ",
            "耶利米书**耶  ",
            "耶利米哀歌**哀 ",
            "西番雅书**番  ",
            "诗篇**诗",
            "路得记**得   ",
            "那鸿书**鸿   ",
            "阿摩司书**摩  ",
            "雅歌**歌"
        ));
my $combobox1=$mw->new_ttk__combobox(-textvariable=>\$bookName);
$combobox1->configure(-values=>$combobox1_vs );
$combobox1->g_bind("<<ComboboxSelected>>", \&selectCombobox1);
my $combobox2_vs=join(" ",(
            "------新约----- ",
            "以弗所书**弗 ",
            "使徒行传**徒 ",
            "加拉太书**加 ",
            "启示录**启 ",
            "哥林多前书**林前",
            "哥林多后书**林后",
            "希伯来书**来 ",
            "帖撒罗尼迦前书**帖前",
            "帖撒罗尼迦后书**帖后",
            "彼得前书**彼前",
            "彼得后书**彼后",
            "提多书**多 ",
            "提摩太前书**提前",
            "提摩太后书**提后",
            "歌罗西书**西 ",
            "犹大书**犹 ",
            "约翰一书**约一",
            "约翰三书**约三",
            "约翰二书**约二",
            "约翰福音**约 ",
            "罗马书**罗 ",
            "腓利门书**门 ",
            "腓立比书**腓 ",
            "路加福音**路 ",
            "雅各书**雅 ",
            "马可福音**可 ",
            "马太福音**太 "
        ));
my $combobox2=$mw->new_ttk__combobox(-textvariable=>\$bookName);
$combobox2->configure(-values=>$combobox2_vs );
$combobox2->g_bind("<<ComboboxSelected>>", \&selectCombobox2);
my $isHgb;
my $checkbutton_hgb=$mw->new_ttk__checkbutton(-text=>"CN",-variable=>\$isHgb,-command=>\&checkbutton_hgb);
$checkbutton_hgb->invoke();
my $isKjv;
my $checkbutton_kjv=$mw->new_ttk__checkbutton(-text=>"KJV",-variable=>\$isKjv,-command=>\&checkbutton_kjv);
my $isBbe;
my $checkbutton_bbe=$mw->new_ttk__checkbutton(-text=>"BBE",-variable=>\$isBbe,-command=>\&checkbutton_bbe);
my $isEsv;
my $checkbutton_esv=$mw->new_ttk__checkbutton(-text=>"ESV",-variable=>\$isEsv,-command=>\&checkbutton_esv);
my $isEditMode;
my $checkbutton_edit=$mw->new_ttk__checkbutton(-text=>"EDIT MODE",-variable=>\$isEditMode, -underline =>4);
$checkbutton_edit->instate("background");
my $label2=$mw->new_ttk__label(-text=>"输入 章(例：3)");
my $chaperNum;
my $entry2=$mw->new_ttk__entry(-textvariable=>\$chaperNum);
my $label3=$mw->new_ttk__label(-text=>"输入 节(例：1-3 或 1-3,5-4)：");
my $sectionNum;
my $entry3=$mw->new_ttk__entry(-textvariable=>\$sectionNum);
my $button_run=$mw->new_ttk__button(-text=>"getChapter&SectionText",-command=>\&getBibleText);
my $label_srch=$mw->new_ttk__label(-text=>"全文搜索");
my $searchStr;
my $entry_srch=$mw->new_ttk__entry(-textvariable=>\$searchStr);
my $button_srch=$mw->new_ttk__button(-text=>"Search",-command=>\&search);  
# A Frame Defined 
my $frame_txt=$mw->new_ttk__frame();
my $text_1=$frame_txt->new_tk__text(-width=>150,-height=>50);
my $srl_y = $frame_txt-> new_ttk__scrollbar(-orient=>'vertical',-command=>[$text_1,'yview']);
$text_1 -> configure(-yscrollcommand=>[$srl_y,'set']);
$text_1->g_bind('<Double-ButtonPress-1>', sub { doubleClk() });
$text_1->g_bind('<Control-a>',sub{print "invoke event ctrl+a \n";});
$text_1->g_bind('<Control-s>',sub{writeTextToDB()});

#GUI Grid Setting 
$label1->g_grid(-row =>1, -column => 1,-columnspan=>1);
$entry1->g_grid(-row =>1, -column => 2,-columnspan=>1);
$combobox1->g_grid(-row =>1, -column => 3,-columnspan=>1);
$combobox2->g_grid(-row =>1, -column => 4,-columnspan=>1);
$checkbutton_hgb->g_grid(-row =>1, -column => 5,-columnspan=>1);
$checkbutton_kjv->g_grid(-row =>1, -column => 6,-columnspan=>1);
$checkbutton_bbe->g_grid(-row =>1, -column => 7,-columnspan=>1);
$checkbutton_esv->g_grid(-row =>1, -column => 8,-columnspan=>1);
$checkbutton_edit->g_grid(-row =>3, -column => 7,-columnspan=>1);
$label2->g_grid(-row =>2, -column => 1,-columnspan=>1);
$entry2->g_grid(-row =>2, -column => 2,-columnspan=>1);
$label3->g_grid(-row =>2, -column => 3,-columnspan=>1);
$entry3->g_grid(-row =>2, -column => 4,-columnspan=>1);
$button_run->g_grid(-row =>2, -column => 5,-columnspan=>2);
$label_srch->g_grid(-row =>3, -column => 1,-columnspan=>1);
$entry_srch->g_grid(-row =>3, -column => 2,-columnspan=>1);
$button_srch->g_grid(-row =>3, -column => 3,-columnspan=>1 );
$frame_txt->g_grid(-row =>5, -column => 1,-columnspan=>8,-sticky => "nwes");
$text_1->g_grid(-row =>1, -column => 1,-columnspan=>8);
$srl_y->g_grid(-row=>1,-column=>9,-sticky=>"ens");

##
my $displayAction="";   # mark the last diplay in text area is called by  "search" button  or "getChapter&SectionText"
# functions definition  
sub  selectCombobox1{
} 
sub  selectCombobox2{

} 
sub checkbutton_hgb{ 
 }
sub checkbutton_kjv{ 
 }
sub checkbutton_bbe{ 
 }
sub checkbutton_esv{ 
 }

sub Search{ 
 # input code here 
 } 
Tkx::MainLoop();

## function begin here
sub getSeleBkName {
    my @book = split(/\*\*/, shift);
    # $entry1->delete(0, 30);
    # $entry1->insert(0, $book[0]);
    return $book[0];
}
# function to get language type
sub getLangTypeForSQL{
	my $secTypeCond="sectionType in ";
	my @que=($isHgb,$isKjv,$isBbe,$isEsv);
	my @queTmp=("[hgb]","[kjv]","[bbe]","[esv]");
	my @queStr;
	for(my $i=0;$i<scalar(@que);$i++){
		if($que[$i]){ push @queStr,$queTmp[$i];}
	}
	return $secTypeCond."(\"".join ("\",\"",@queStr)."\")";
}
# function to search out bible text by
sub getBibleText {
    my $book     = getSeleBkName($entry1->get());
    my $chapter  = $entry2->get();
    my $sections = $entry3->get();
    $displayAction ="getChapter&SectionText";
#SQL=#  select sectionContent from bible where bookNameCN=? and chapterNumber=? and sectionNumber=? and sectionType="[hgb]";
#    my $sth_1 = $dbh->prepare(
# qq{select sectionContent from bible where bookNameCN=? and chapterNumber=? and sectionNumber  ? and sectionType='[hgb]';});
    my $v_bookNameCN    = $book;
    my $v_chapterNumber = $chapter;
    $sections =~ s/\s*//g;    # remove all space in sections input
    my @seclist = split(/\,/, $sections)
      ; # sections fields can be input mutiple sections as ? or ?-? or ?,?-?  or ?-?,? or ?-?,?-? ,split with ,
    my $v_sectionContent = "";
    my $conditionP       = 1
      ; # default condition for section search always true , means any sections selected
    my $secfrmto;
    my $secTypeCond =getLangTypeForSQL();
    # db handler define
    my $sth_1;

    if ($sections eq "")    # for there is no input in sections, fetch all sections
    {   
        $sth_1 = $dbh->prepare(
"select sectionContent, sectionType,sectionNumber from bible where bookNameCN=\"$v_bookNameCN\" and chapterNumber=\"$v_chapterNumber\"  and $conditionP and  $secTypeCond"
        );
        $sth_1->execute();
        my @row_1;
        my $sec_num =
          1;    # count section number from 1 ,display in each section head
        $v_sectionContent =
            $v_sectionContent . "\n"
          . encode("utf8", "$v_bookNameCN")
          . "$v_chapterNumber"
          . encode("utf8", "章") . "\n";
        while (@row_1 = $sth_1->fetchrow_array) {
            $v_sectionContent =
                $v_sectionContent
              . $chapter . ":"
              . $row_1[2] . " "
              . $row_1[0] . "\n";
        }
        $sth_1->finish;
    }
    else {    # for input in sections
        foreach $secfrmto (@seclist) {
            my $buffer = "";

# $v_sectionContent =encode("utf8","$v_bookNameCN")."$v_chapterNumber  $secfrmto  \n". $v_sectionContent . "\n";
            $buffer = "\n"
              . encode("utf8", "$v_bookNameCN")
              . "$v_chapterNumber"
              . encode("utf8", "章")
              . " $secfrmto "
              . encode("utf8", "节")
              . $buffer . "\n";
            my @secfromto     = split(/\-/, $secfrmto);
            my $v_section_frm = 0;
            my $v_section_end = 0;
            $conditionP = 1;

            if ($secfromto[0]) {
                $v_section_frm = $secfromto[0];
                $conditionP    = " sectionNumber=$v_section_frm";
                if ($secfromto[1]) {
                    $v_section_end = $secfromto[1];
                    $conditionP =
" sectionNumber>=$v_section_frm and sectionNumber<=$v_section_end";
                }
            }

            # open file to
            # print "is utf8? " . utf8::is_utf8($v_bookNameCN) . "\n";
            # get dB
            $sth_1 = $dbh->prepare(
"select sectionContent,sectionType,sectionNumber from bible where bookNameCN=\"$v_bookNameCN\" and chapterNumber=\"$v_chapterNumber\"  and $conditionP and  $secTypeCond"
            );

# print "select sectionContent from bible where bookNameCN =\"$v_bookNameCN\" and chapterNumber=\"$v_chapterNumber\"  and $conditionP and  $secTypeCond\n";
            $sth_1->execute();
# $v_sectionContent=$v_sectionContent.$v_bookNameCN."-$v_chapterNumber $sections \n";
            my @row_1;
            my $sec_num = $v_section_frm;
            while (@row_1 = $sth_1->fetchrow_array) {
                $buffer =
                  $buffer . $chapter . ":" . $row_1[2] . " " . $row_1[0] . "\n";

            }
            $v_sectionContent = $v_sectionContent . $buffer;
            $sth_1->finish;
        }

    }
    my $unicode_cn = decode('utf8', $v_sectionContent);
    
    my $gbk_cn = encode("gbk", $unicode_cn);

    # print "$gbk_cn \n";
    #Tk : $text_1->Contents($unicode_cn);
    $text_1->delete("1.0","end");
    $text_1->insert("1.0",$unicode_cn);

}

#This happens at double-click
sub doubleClk {
    my $ctxts = $text_1->get("1.0", "end");
    my $content=$ctxts.("\n\n 点击\"阅读原文\"在线收听 \n");
    ## perl clipboard , not work for chinese characters
    # my $CLIP = Win32::Clipboard();
    # $CLIP->Empty();
    # $CLIP->text("CF_UNICODETEXT"):
    # $CLIP->Set("这是啥");
    ## Tkx reference ,clipboard
    #http://www.tcl.tk/man/tcl8.5/TkCmd/contents.htm
    Tkx::clipboard clear;
    Tkx::clipboard append($content);

}
sub xcode {
    # xcode("string",'Mode'); Mode = x(hex), b(bin), d(int)
    for my $v ( split(//,$_[0]) ) {
        print sprintf ("%l$_[1] ",ord($v));
    }
    print "\n\n";
}

# function to search bible contents accroding to search key words input
sub search {
    my $srchStr = $entry_srch->get();
    my $conditionKeys = "sectionContent like \"\%" . join("\%\" or sectionContent like \"\%", ($srchStr =~ /\S+/g)) . "\%\"";
    $displayAction ="search";
    # my $dbargs = { PrintError => 1 };
    # print "Debug: " . encode('gb2312', $conditionKeys) . "\n";

    #SQL=#  select bookNameCN,chapterNumber,sectionNumber,sectionContent from bible where sectionType="[hgb]" and ( ?)
    my $sth_1 = $dbh->prepare("select bookNameCN,chapterNumber,sectionNumber,sectionContent from bible where sectionType=\"[hgb]\"and (".$conditionKeys.")");
    #print "Debug: select bookNameCN,chapterNumber,sectionNumber,sectionContent from bible where sectionType=\"[hgb]\"and (".$conditionKeys.")"."\n";
    $sth_1->execute();
    my @row_1;
    my $res = " ";

    while (@row_1 = $sth_1->fetchrow_array) {	     
        my $v_bookNameCN     = $row_1[0];
        my $v_chapterNumber  = $row_1[1];
        my $v_sectionNumber  = $row_1[2];
        my $v_sectionContent = $row_1[3];
        $res              = $res
          . "$v_bookNameCN : $v_chapterNumber - $v_sectionNumber : $v_sectionContent \r\n";
          
    }
    my $unicode_cn = decode('utf8', $res);
    my $gbk_cn = encode("gbk", $unicode_cn);

    # print "$gbk_cn \n";
    ## set Text contents
    $text_1->delete("1.0","end");
    $text_1->insert("1.0",$unicode_cn);
    $sth_1->finish;

}
my %bookFieldsMap=(
"以弗所书" =>["以弗所书Ephesians","Ephesians","NT","弗"],
"以斯帖记" =>["以斯帖记Esther","Esther","OT","斯"],
"以斯拉记" =>["以斯拉记Ezra","Ezra","OT","拉"],
"以西结书" =>["以西结书Ezekiel","Ezekiel","OT","结"],
"以赛亚书" =>["以赛亚书Isaiah","Isaiah","OT","赛"],
"传道书"  =>["传道书Ecclesiastes","Ecclesiastes","OT","传"],
"但以理书" =>["但以理书Daniel","Daniel","OT","但"],
"何西阿书" =>["何西阿书Hosea","Hosea","OT","何"], 
"使徒行传" =>["使徒行传Acts","Acts","NT","徒"],
"俄巴底亚书"=>["俄巴底亚书Obadiah","Obadiah","OT","俄"],
"出埃及记" =>["出埃及记Exodus","Exodus","OT","出"],
"列王纪上" =>["列王记上1Kings","Kings1","OT","王上"],
"列王纪下" =>["列王记下2Kings","Kings2","OT","王下"],
"创世纪"  =>["创世纪Genesis","Genesis","OT","创"],
"利未记"  =>["利未记Leviticus","Leviticus","OT","利"],
"加拉太书" =>["加拉太书Galatians","Galatians","NT","加"],
"历代志上" =>["历代志上1Chronicles","Chronicles1","OT","代上"],
"历代志下" =>["历代志下2Chronicles","Chronicles2","OT","代下"],
"启示录"  =>["启示录Revelation","Revelation","NT","启"],
"哈巴谷书" =>["哈巴谷书Habakkuk","Habakkuk","OT","哈"],
"哈该书"  =>["哈该书Haggai","Haggai","OT","该"],
"哥林多前书"=>["哥林多前书1Corinthians","Corinthians1","NT","林前"],
"哥林多后书"=>["哥林多后书2Corinthians","Corinthians2","NT","林后"],
"士师记"  =>["士师记Judges","Judges","OT","士"],
"尼希米记" =>["尼希米记Nehemiah","Nehemiah","OT","尼"],
"希伯来书" =>["希伯来书Hebrews","Hebrews","NT","来"],
"帖撒罗尼迦前书"=>["帖撒罗尼迦前书1Thessalonians","Thessalonians1","NT","帖前"],
"帖撒罗尼迦后书"=>["帖撒罗尼迦后书2Thessalonians","Thessalonians2","NT","帖后"],
"弥迦书"   =>["弥迦书Micah","Micah","OT","弥"],
"彼得前书"  =>["彼得前书1Peter","Peter1","NT","彼前"],
"彼得后书"  =>["彼得后书2Peter","Peter2","NT","彼后"],
"提多书"   =>["提多书Titus","Titus","NT","多"],
"提摩太前书" =>["提摩太前书1Timothy","Timothy1","NT","提前"],
"提摩太后书" =>["提摩太后书2Timothy","Timothy2","NT","提后"],
"撒母耳记上" =>["撒母耳记上1Samuel","Samuel1","OT","撒上"],
"撒母耳记下" =>["撒母耳记下2Samuel","Samuel2","OT","撒下"],
"撒迦利亚书" =>["撒迦利亚Zechariah","Zechariah","OT","亚"],
"歌罗西书"  =>["歌罗西书Colossians","Colossians","NT","西"],
"民数记"   =>["民数记Numbers","Numbers","OT","民"],
"犹大书"   =>["犹大书Jude","Jude","NT","犹"],
"玛拉基书"  =>["玛拉基书Malachi","Malachi","OT","玛"],
"申命记"   =>["申命记Deuteronomy","Deuteronomy","OT","申"],
"箴言"    =>["箴言Proverbs","Proverbs","OT","箴"],
"约书亚记"  =>["约书亚记Joshua","Joshua","OT","书"],
"约伯记"   =>["约伯记Job","Job","OT","伯"],
"约拿书"   =>["约拿书Jonah","Jonah","OT","拿"],
"约珥书"   =>["约珥书Joel","Joel","OT","珥"],
"约翰一书"  =>["约翰一书1John","John1","NT","约一"],
"约翰三书"  =>["约翰三书3John","John3","NT","约三"],
"约翰二书"  =>["约翰二书2John","John2","NT","约二"],
"约翰福音"  =>["约翰福音John","John","NT","约"],
"罗马书"   =>["罗马书Romans","Romans","NT","罗"],
"耶利米书"  =>["耶利米书Jeremiah","Jeremiah","OT","耶"],
"耶利米哀歌" =>["耶利米哀歌Lamentations","Lamentations","OT","哀"],
"腓利门书"  =>["腓利门书Philemon","Philemon","NT","门"],
"腓立比书"  =>["腓立比书Philippians","Philippians","NT","腓"],
"西番雅书"  =>["西番雅书Zephaniah","Zephaniah","OT","番"],
"诗篇"    =>["诗篇Psalms","Psalms","OT","诗"],
"路加福音"  =>["路加福音Luke","Luke","NT","路"],
"路得记"   =>["路得记Ruth","Ruth","OT","得"],
"那鸿书"   =>["那鸿书Nahum","Nahum","OT","鸿"],
"阿摩司书"  =>["阿摩司书Amos","Amos","OT","摩"],
"雅各书"   =>["雅各书James","James","NT","雅"],
"雅歌"    =>["雅歌SongofSongs","SongofSongs","OT","歌"],
"马可福音"  =>["马可福音Mark","Mark","NT","可"],
"马太福音"  =>["马太福音Matthew","Matthew","NT","太"]);
sub writeTextToDB{
    my $response; 
    if($isEditMode && $isHgb && !$isKjv && !$isBbe && !$isEsv){
    	 $response= Tkx::tk___messageBox(-type =>"yesno", -message => " Do you want to save modified content to DB ? ",-icon =>"question");
    	 if($response){
    	 	 if($displayAction eq "getChapter&SectionText"){
    	 	 	 my @bookNames=split(/\*\*/,getSeleBkName($entry1->get()));
    	 	 	 my $bookName_cn=$bookNames[0];
    	 	 	 my $bookname=$bookFieldsMap{$bookName_cn}[0];
    	 	 	 my $bookname_en=$bookFieldsMap{$bookName_cn}[1];
    	 	 	 my $booktype=$bookFieldsMap{$bookName_cn}[2];
    	 	 	 my $cnNameAbbr=$bookFieldsMap{$bookName_cn}[3];
    	 	 	 my $chapter= $entry2->get();
    	 	 	# my $sections_colects= $entry3->get();
    	 	 	 my $secContent="";
    	 	 	 my $ctxts = encode("utf-8",$text_1->get("1.0", "end"));  ## must change to utf-8 , to easy get RGX match
    	 	 	 open TXT,"<",\$ctxts;
    	 	 	 while(<TXT>){
    	 	 	 	 chomp();
    	 	 	 	 $_=~s/(^\s+)||(\s+$)//g;
    	 	 	 	if(!($_ eq "")&&($_!~/${bookName_cn}/g)&&($_=~m/([\d]+):([\d]+)\s*(.*)\s*$/g)){
    	 	 	 	  $secContent=$3;
    	 	 	 	  # ## update db
    	 	 	 	  # #SQL=#  update bible set sectionContent=$secContent  where setionType="[hgb]" and bookNameCN=$bookName_cn and bookName = $bookname  and chapterNumber=$chapter and sectionNumber=$sectionnumber
    	 	 	 	  my $upth_1=$dbh->prepare(qq{update bible set sectionContent=? where sectionType="[hgb]" and bookNameCN=? and chapterNumber=? and sectionNumber=?}) or die $dbh->errstr;
    	 	 	 	  $upth_1->execute($secContent,${bookName_cn},$1,$2);
    	 	 	 	  $dbh->commit;
    	 	 	 	  $upth_1->finish;
    	 	 	 	 }
    	 	 	 }
    	 	 	
    	 	 }
    	 }
    }else{
    	Tkx::tk___messageBox(-message => "如果你需要存盘请勾选编辑模式 EditMode , 而且只能勾选[CN] 一种圣经!");
    }
}
$dbh->disconnect;
# container1={type:MainWindow,name:mw}   
# Label1={can:mw,txt:圣经书名:,row:1,col:1,colspan:1}
# entry1={can:mw,txtvar:bookName,row:1,col:2,colspan:1}
# Combobox1={can:mw,txtvar:bookName,options:aaa|bbb|ccc,row:1,col:3,colspan:1}
# Combobox2={can:mw,txtvar:bookName,options:aaa|bbb|ccc,row:1,col:4,colspan:1}
# checkbutton_hgb={can:mw,txt:CN,var:isHgb,value:checked,row:1,col:5,colspan:1}
# checkbutton_kjv={can:mw,txt:KJV,var:isKjv,value:unchecked,row:1,col:6,colspan:1}
# checkbutton_bbe={can:mw,txt:BBE,var:isBbe,value:unchecked,row:1,col:7,colspan:1}
# checkbutton_esv={can:mw,txt:ESV,var:isEsv,value:unchecked,row:1,col:8,colspan:1}
# Label2={can:mw,txt:输入 章(例：3):,row:2,col:1,colspan:1}
# entry2={can:mw,txtvar:chaperNum,row:2,col:2,colspan:1}
# Label3={can:mw,txt:输入 节(例：1-3 或 1-3.5-4)：,row:2,col:3,colspan:1}
# entry3={can:mw,txtvar:sectionNum,row:2,col:4,colspan:1}
# Button_run={can:mw,txt:run,row:2,col:5,colspan:2}
# Label_srch={can:mw,txt:搜索:,row:3,col:1,colspan:1}
# Entry_srch={can:mw,txtvar:searchStr,row:3,col:2,colspan:1,}
# Button_srch={can:mw,txt:Search,row:3,col:3,colspan:1 }
# Frame_txt={can:mw,row:5,col:1,colspan:8}
# Text_1={can:frame_txt,width:150,height:70,row:1,col:1,colspan:8}
# Messagebox_save={can:mw,type:yesno,var:response,msg: Do you want to save modified content to DB ?};
# Alert_mention={msg:"如果你需要存盘请勾选编辑模式 EditMode !"};