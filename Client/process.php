<?php

    error_reporting(~E_ALL);
    if ($_GET['p'] == 'login') {
        $login = 'false';
        switch ($_POST['user']) {
            case '2012-01065':
                if ($_POST['password'] == 'pewpewpew') {
                    $login = 'true';
                    $name = 'Ferriel Melarpis';
                    $lastLogin = '1/24/14';
                    $units = '18';
                    $icon = 'images/yhel.jpg';
                }
                break;
            case 'bulacs':
                if ($_POST['password'] == 'pewpewpew') {
                    $login = 'true';
                    $name = 'Rommel Bulalacao';
                    $lastLogin = '2/3/14';
                    $units = '18';
                    $icon = 'images/bulacs.png';
                }
                break;
            case 'keith':
                if ($_POST['password'] == 'pewpewpew') {
                    $login = 'true';
                    $name = 'Jan Keith Darunday';
                    $lastLogin = '2/3/14';
                    $units = '18';
                    $icon = 'images/account-circle-icon.png';
                }
                break;
        }

        if ($login == 'true') {
            $message = 'You have succesfully logged in!';
            echo <<<ASD
            {
                "user":{
                    "name": "$name",
                    "lastLogin": "$lastLogin",
                    "units": "$units",
                    "icon": "$icon",
                    "sessionID": "8f2a08cfcdd821c6334a8bcb5e058961"
                },
                "message": "$message {$_POST[0]}"
            }
ASD;
        } else {
            $message = 'You have entered invalid login credentials.';
        }
    }

    if ($_GET['p'] == 'home' || $_GET['p'] == 'checklist' || $_GET['p'] == 'enlistment' || $_GET['p'] == 'dreamsched') {
        $lipsum = <<<LI
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse sed dolor purus. Morbi a adipiscing neque, nec venenatis arcu. Morbi a diam iaculis mi pellentesque mollis ac id est. Sed elementum sed purus in accumsan. Pellentesque dignissim, lorem sollicitudin luctus dictum, magna nisi elementum massa, ut elementum lorem leo id enim. Phasellus non vehicula ligula. Aliquam vehicula posuere nunc nec pulvinar. Nulla vestibulum nec ligula eget laoreet. Cras risus leo, condimentum eu ligula a, sodales eleifend eros. Vivamus varius viverra varius. Donec tellus nisl, tristique et purus non, pharetra interdum ante. Aenean non purus leo. Vivamus ut neque lectus.</p><p>Vivamus lobortis interdum ornare. Morbi porttitor lacinia nunc et lobortis. Duis vulputate et enim pretium suscipit. Aenean gravida eros non nisi molestie porttitor. Curabitur non leo dui. Cras iaculis, dui sit amet vestibulum semper, nunc diam gravida massa, sed facilisis tortor metus vitae magna. Sed id ante congue, varius urna vitae, varius elit.</p>
<p>Praesent vehicula at purus a auctor. Fusce pharetra sapien sit amet velit volutpat vulputate. Etiam at libero ac tortor euismod blandit et eget elit. Morbi at interdum turpis. Etiam id luctus lectus, at ultricies lorem. Integer lacinia ut felis varius bibendum. Maecenas sed eleifend justo. Donec facilisis enim mi, ac aliquet mauris vestibulum eget. Proin semper dictum turpis sed pulvinar. Mauris mollis, dolor id molestie luctus, nunc urna aliquam nibh, a imperdiet nisi elit et velit.</p>
<p>Maecenas bibendum, sapien nec bibendum interdum, turpis nisl vestibulum sem, id tempor magna nibh nec est. Nam vel sodales nunc. Nullam eleifend libero mi. Fusce pulvinar mauris non nisi cursus fringilla. Sed vitae congue sem. Aliquam erat volutpat. Aliquam erat volutpat. Maecenas pretium non orci eget lacinia. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Ut ullamcorper lacus est, nec tincidunt erat eleifend vitae. Sed sollicitudin nunc nec metus hendrerit cursus. Pellentesque eget elit purus. Donec at suscipit dui. Pellentesque vestibulum lectus sit amet arcu aliquam pellentesque id sed ante. Maecenas facilisis, augue id euismod semper, sem nibh porttitor mi, id interdum mi arcu commodo neque.</p>

<p>Integer id mauris eu arcu luctus interdum. Nam hendrerit, ante non lacinia laoreet, orci augue commodo lacus, et mattis ligula leo eu nibh. Mauris urna purus, euismod vitae eleifend sed, pretium a metus. Phasellus pellentesque rutrum nulla, eu dictum dolor euismod id. Morbi at risus mauris. In lectus nibh, venenatis sit amet dapibus quis, mattis convallis nisl. Vivamus fermentum tempor malesuada. Ut sodales risus vel semper pharetra. In euismod dignissim magna, id commodo orci facilisis ut. Nam purus magna, malesuada ac ligula eu, scelerisque tristique nulla.</p>

<p>Donec facilisis non justo et pellentesque. Proin sagittis arcu eu est dignissim mattis. Aliquam ac orci interdum, sollicitudin neque in, lobortis leo. Donec at adipiscing magna, a tincidunt justo. Sed accumsan dui et dui sagittis facilisis in eu turpis. Nulla mi sem, bibendum sit amet imperdiet et, tincidunt ullamcorper diam. Duis vehicula auctor eros non condimentum. Etiam feugiat nunc lacus, id blandit quam vehicula a.</p>

<p>Suspendisse id lorem eu orci fermentum eleifend. Donec a dui rutrum, vulputate nisl vitae, tristique quam. Pellentesque a elit malesuada, gravida nunc in, ultrices lorem. Aliquam vitae commodo nunc. Donec et accumsan dui. Suspendisse feugiat, orci sed dapibus posuere, nulla ipsum rutrum mi, iaculis lacinia arcu mauris at turpis. In in lorem a felis congue elementum.</p>

<p>Nunc nunc risus, condimentum nec eleifend quis, pharetra volutpat libero. In quis dolor vehicula, cursus metus luctus, pulvinar sapien. Proin risus est, cursus ut turpis et, hendrerit pharetra mi. Donec id faucibus ipsum. Maecenas vel convallis diam. Mauris faucibus nibh at laoreet sodales. Suspendisse dignissim diam nec viverra feugiat. Aenean sagittis elit nec euismod viverra. Vestibulum purus urna, pharetra sit amet leo vestibulum, pharetra varius neque. Duis purus tortor, rhoncus dapibus vestibulum a, pretium in tellus. Quisque ut lacinia enim, non interdum metus. Mauris aliquam ut augue sed ornare. Curabitur congue sollicitudin nibh non tristique. Praesent vestibulum, velit in eleifend scelerisque, leo eros aliquam erat, vitae molestie est lectus eu arcu.</p>

<p>Phasellus posuere neque risus, vitae egestas augue hendrerit ac. Pellentesque felis diam, ornare fringilla nunc vel, facilisis blandit urna. Ut hendrerit, dolor imperdiet facilisis aliquam, urna dolor suscipit turpis, at pretium lorem arcu eget lacus. Maecenas eget consectetur neque, dictum convallis lectus. Praesent hendrerit dolor id mi luctus ultrices. Fusce a varius ligula. Ut luctus sem at cursus congue. Maecenas egestas sed erat id suscipit. Nam porta diam metus, sed porttitor libero aliquet quis.</p>

<p>In faucibus hendrerit ullamcorper. Vestibulum tincidunt vulputate urna et facilisis. Proin feugiat mauris vel tortor molestie, in faucibus quam dignissim. Nunc sit amet ornare orci. Vestibulum nibh tellus, tempus quis porta vel, vulputate ac velit. Vestibulum mattis sit amet nunc ut tempus. Curabitur hendrerit scelerisque quam ac dignissim. Cras tempor, ante vitae porta faucibus, elit enim suscipit tellus, eu pretium est lectus et dolor. Nulla ornare nibh a sem tincidunt, eu semper magna viverra. Etiam dignissim vehicula libero, id congue felis fringilla quis. Pellentesque sit amet gravida tortor, eu dictum dui. Phasellus sem libero, volutpat euismod risus et, porta sollicitudin urna. Integer tincidunt justo dui, quis vestibulum massa auctor a. Aenean eu nibh in libero placerat facilisis at at neque. In hac habitasse platea dictumst. </p>
LI;
        $lipsum2 = preg_replace("/\n/", '\\n', $lipsum);
        echo <<<ASD
{
    "data": [
        {
            "title": "Experimental Site is Now Up",
            "body": "And so, we have an experimental site.",
            "author": "Keith Certeza",
            "date": "Tue Feb 11 19:57:24 JST 2014"
        },
        {
            "title": "Lorem Ipsum",
            "body": "$lipsum2",
            "author": "Rommel Bulalacao",
            "date": "Tue Feb 11 19:57:24 JST 2014"
        }
    ]
}
ASD;
    }
