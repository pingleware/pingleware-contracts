function generate(name,wallet,public_key,private_key,qrcode,mnemonic,mailing,csz,letterDate,pan,live="https://redeecash.exchange/",test="https://testnet.redeecash.exchange/") {
    return `<?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0//EN" "http://www.w3.org/Math/DTD/mathml2/xhtml-math11-f.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US">
    <!--This file was converted to xhtml by LibreOffice - see https://cgit.freedesktop.org/libreoffice/core/tree/filter/source/xslt for the code.-->
    
    <head profile="http://dublincore.org/documents/dcmi-terms/">
    <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8"/>
    <title xml:lang="en-US">- no title specified</title>
    <meta name="DCTERMS.title" content="" xml:lang="en-US"/>
    
    <meta name="DCTERMS.language" content="en-US" scheme="DCTERMS.RFC4646"/>
    <meta name="DCTERMS.source" content="http://xml.openoffice.org/odf2xhtml"/>
    
    <meta name="DCTERMS.issued" content="2023-12-21T02:16:50" scheme="DCTERMS.W3CDTF"/>
    
    <meta name="DCTERMS.modified" content="2023-12-22T05:52:09.118965135" scheme="DCTERMS.W3CDTF"/>
    <meta name="DCTERMS.provenance" content="Printed by &quot;PDF files&quot;[dc:publisher] on &quot;2023-12-22T05:52:39.811629828&quot;[dc:date] in &quot;en-US&quot;[dc:language]" xml:lang="en-US"/>
    
    <meta name="xsl:vendor" content="libxslt"/>
    <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" hreflang="en"/>
    <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/" hreflang="en"/>
    <link rel="schema.DCTYPE" href="http://purl.org/dc/dcmitype/" hreflang="en"/>
    <link rel="schema.DCAM" href="http://purl.org/dc/dcam/" hreflang="en"/>
    
    <style>
        table { border-collapse:collapse; border-spacing:0; empty-cells:show }
        td, th { vertical-align:top; font-size:12pt;}
        h1, h2, h3, h4, h5, h6 { clear:both;}
        ol, ul { margin:0; padding:0;}
        li { list-style: none; margin:0; padding:0;}
        span.footnodeNumber { padding-right:1em; }
        span.annotation_style_by_filter { font-size:95%; font-family:Arial; background-color:#fff000;  margin:0; border:0; padding:0;  }
        span.heading_numbering { margin-right: 0.8rem; }* { margin:0;}
        .graphic-fr1{ background-color:transparent; font-size:12pt; font-family:'Liberation Serif'; vertical-align:top; writing-mode:horizontal-tb; direction:ltr; border-top-style:none; border-left-style:none; border-bottom-style:none; border-right-style:none; margin-left:0in; margin-right:0in; margin-top:0in; margin-bottom:0in; padding:0in; }
        .paragraph-P1{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; font-style:italic; }
        .paragraph-P10{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; font-weight:bold; }
        .paragraph-P3{ font-size:12pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P4{ font-size:12pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P5{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P6{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P7{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P8{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .paragraph-P9{ font-size:8pt; margin-bottom:0in; margin-top:0in; text-align:left ! important; font-family:'Liberation Serif'; writing-mode:horizontal-tb; direction:ltr; }
        .table-Table1{ width:6.9264in; margin-left:0in; margin-top:0in; margin-bottom:0in; margin-right:auto;writing-mode:horizontal-tb; direction:ltr;}
        .cell-Table1_A1{ padding:0.0382in; border-left-width:0.0176cm; border-left-style:solid; border-left-color:#000000; border-right-style:none; border-top-width:0.0176cm; border-top-style:solid; border-top-color:#000000; border-bottom-width:0.0176cm; border-bottom-style:solid; border-bottom-color:#000000; }
        .cell-Table1_A2{ padding:0.0382in; border-left-width:0.0176cm; border-left-style:solid; border-left-color:#000000; border-right-style:none; border-top-style:none; border-bottom-width:0.0176cm; border-bottom-style:solid; border-bottom-color:#000000; }
        .cell-Table1_B1{ border-top-width:0.0176cm; border-top-style:solid; border-top-color:#000000; border-left-width:0.0176cm; border-left-style:solid; border-left-color:#000000; border-bottom-width:0.0176cm; border-bottom-style:solid; border-bottom-color:#000000; border-right-width:0.0176cm; border-right-style:solid; border-right-color:#000000; padding:0.0382in; }
        .cell-Table1_B2{ padding:0.0382in; border-left-width:0.0176cm; border-left-style:solid; border-left-color:#000000; border-right-width:0.0176cm; border-right-style:solid; border-right-color:#000000; border-top-style:none; border-bottom-width:0.0176cm; border-bottom-style:solid; border-bottom-color:#000000; }
        .col-Table1_A{ width:1.2222in; }
        .col-Table1_B{ width:0.0625in; }
        .col-Table1_C{ width:2.0028in; }
        .col-Table1_D{ width:1.1771in; }
        .col-Table1_E{ width:2.4618in; }
        .text-Internet_20_link{ color:#000080; text-decoration:underline; }
        .text-T2{ font-weight:bold; }
        .text-T4{ font-size:8pt; }
        /* ODF styles with no properties representable as CSS:
        .dp1 .Table1.1  { } */
    </style>
    </head>
    
    <body dir="ltr" style="max-width:8.5in;margin-top:0.7874in; margin-bottom:0.7874in; margin-left:0.7874in; margin-right:0.7874in; ">
    
    <p class="paragraph-P3">${name}</p>
    
    <p class="paragraph-P3">${mailing}</p>
    
    <p class="paragraph-P3">${csz}</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">${letterDate}</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">Subject: Welcome to REDEECASH EXCHANGE - Your Gateway to a Decentralized Future!</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">Dear ${name},</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">Congratulations and welcome to REDEECASH EXCHANGE! I am thrilled to have you as a prequalified member of the new blockchain-based National Market System (NMS) and Self-Regulatory Organization (SRO). Your participation is a crucial step toward shaping the future of decentralized finance, and I am excited to embark on this journey with you.</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">As a prequalified member, you are at the forefront of the blockchain revolution, and your commitment to REDEECASH EXCHANGE is truly appreciated. To facilitate your seamless onboarding process, I have generated a wallet address along with key pairs specifically for you:</p>
    <p class="paragraph-P3"> </p>
    
    <table border="0" cellspacing="0" cellpadding="0" class="table-Table1"><colgroup><col width="136"/><col width="7"/><col width="222"/><col width="131"/><col width="273"/></colgroup><tr class="row-Table1_1"><td style="text-align:left;width:1.2222in; " class="cell-Table1_A1">
    <p class="paragraph-P9">PAN</p>
    </td><td colspan="4" style="text-align:left;width:0.0625in; " class="cell-Table1_B1">
    <p class="paragraph-P10">${pan}</p>
    </td></tr><tr class="row-Table1_1"><td style="text-align:left;width:1.2222in; " class="cell-Table1_A2">
    <p class="paragraph-P8">Wallet Address</p>
    </td><td colspan="4" style="text-align:left;width:0.0625in; " class="cell-Table1_B2">
    <p class="paragraph-P8"><span class="text-T2">${wallet}</span></p>
    </td></tr><tr class="row-Table1_1"><td style="text-align:left;width:1.2222in; " class="cell-Table1_A2">
    <p class="paragraph-P8">Public Key</p>
    </td><td colspan="4" style="text-align:left;width:0.0625in; " class="cell-Table1_B2">
    <p class="paragraph-P8"><span class="text-T2">${public_key}</span></p>
    </td></tr><tr class="row-Table1_1"><td style="text-align:left;width:1.2222in; " class="cell-Table1_A2">
    <p class="paragraph-P8">Private Key</p>
    </td><td colspan="4" style="text-align:left;width:0.0625in; " class="cell-Table1_B2">
    <p class="paragraph-P8"><span class="text-T2">${private_key}</span></p>
    </td></tr><tr class="row-Table1_1"><td style="text-align:left;width:1.2222in; " class="cell-Table1_A2">
    <p class="paragraph-P9">MNEMONIC</p>
    </td><td colspan="4" style="text-align:left;width:0.0625in; " class="cell-Table1_B2">
    <p class="paragraph-P10">${mnemonic}</p>
    </td></tr><tr class="row-Table1_1"><td colspan="2" style="text-align:left;width:1.2222in; " class="cell-Table1_A2">
    <p class="paragraph-P5">Live Portal URL</p>
    </td><td style="text-align:left;width:2.0028in; " class="cell-Table1_A2">
    <p class="paragraph-P7">${live}</p>
    </td><td style="text-align:left;width:1.1771in; " class="cell-Table1_A2">
    <p class="paragraph-P6">Test Portal URL</p>
    </td><td style="text-align:left;width:2.4618in; " class="cell-Table1_B2">
    <p class="paragraph-P3"><span class="text-T4">${test}</span></p>
    </td></tr></table>
    
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">If you already possess an Ethereum wallet and prefer to use it, you can log into our Member Access Portal using the wallet provided above. Once logged in, you have the option to change your wallet address and complete the onboarding process. I encourage you to update your wallet information promptly to ensure a smooth experience on REDEECASH EXCHANGE.</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">Remember that your participation is not just about transactions; it's about being part of a community dedicated to driving positive change in the financial landscape. I am here to support you every step of the way, and to assist with any questions or concerns you may have.</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">Thank you for choosing REDEECASH EXCHANGE. Together, let's build a decentralized future that empowers individuals and transforms the way we engage with financial markets.</p>
    <p class="paragraph-P3"> </p>
    <!--Next 'div' was a 'text:p'.-->
    <div class="paragraph-P3">Welcome aboard! A QR Code provided for easier wallet importing.</div>
    <!--Next 'div' is a draw:frame. -->
    <div style="height:1.3602in;width:1.3602in; padding:0;  float:left; position:relative; left:13.033cm; top:0.176cm; " class="graphic-fr1" id="Image1"><img style="height:3.4549cm;width:3.4549cm;" alt="" src="data:image/png;base64,${qrcode}"/></div><div style="clear:both; line-height:0; width:0; height:0; margin:0; padding:0;"> </div>
    <p class="paragraph-P3"><span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    <span> </span>
    </p>
    <p class="paragraph-P3">Best Regards,</p>
    <p class="paragraph-P3"> </p>
    <p class="paragraph-P3">PATRICK O. INGLE</p>
    
    <p class="paragraph-P4">Founder</p>
    
    <p class="paragraph-P3">PRESSPAGE ENTERTAINMENT INC dba REDEECASH</p>
    </body>
    </html>`;
}

module.exports = generate;