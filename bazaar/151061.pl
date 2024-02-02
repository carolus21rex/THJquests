#Sulentia, Polymorphist
#(Body Modification)

my $race_change_cost = 10;
my $sex_change_cost  = 5;
my $name_change_cost = 5;

sub EVENT_SAY {
if ($client->GetGM()) {

    my $sex_word;
    if ($client->GetGender()) {
        $sex_word = "masculinity";
    } else {
        $sex_word = "femininity";
    }

    if ($text=~/hail/i) {
        quest::say("Greetings, $name. Do you seek perfection? Are you [". quest::saylink("unhappy with your form", 1) ."]? 
                    Are you interested in embracing [". quest::saylink($sex_word, 1) ."]? 
                    Perhaps, instead you simply desire a [". quest::saylink("new identity", 1) ."] altogether?");
    }

    elsif ($text=~/unhappy with your form/i) {
        quest::say("Just so. If you can properly anchor your memories - perhaps with ". plugin::num2en($race_change_cost) ." [". plugin::EOMLink() ."], I can adjust your form.
                    Be warned, this process is quite traumatic, and you will immediately black out.");
        if (plugin::GetEOM($client) > $race_change_cost) {
            $client->Message(15, "WARNING: You will disconnect immediately upon selecting a new race.");
            $client->Message(15, "WARNING: You may select illegal races for your class. No support will be given for any problems caused as a result.");
            $client->Message(257, " ------- Select a Race ------- ");
            my $races = get_races();
            foreach my $id (sort { $a <=> $b } keys %$races) {
                my $race_name = $races->{$id};              
                if ($client->GetRace() != $id) {
                    $client->Message(257, "-[ " . quest::saylink("RACECHANGE:".$id, 1, $race_name));
                }
            }
        }
    }
    
    elsif ($text=~/new identity/i) {
        quest::say("Sometimes, the memories of our past call to us. We can assume the names of our past or future selves, anchored in time.
                    For a pittance, ". plugin::num2en($name_change_cost) ." [". plugin::EOMLink() ."], I can change the name that you present 
                    to the world. Be aware, all will be made aware of this change for posterity. Do you [". quest::saylink("wish to continue", 1) ."]?");
    }

    elsif ($text=~/wish to continue/i) {
        $client->Message(15, "The next line you say to ". $npc->GetCleanName() ." will be assessed as a potential new name. If it is valid and you have the Echoes of Memory available, your name will be changed. This state will remain active for 1 minute.");
        $client->SetBucket("namechange_active", 1, '60s');
    }

    elsif ($text eq $sex_word) {
        quest::say("Just [". quest::saylink("SEXCHANGE", 1, "say the word") ."], and for the price of a mere ". plugin::num2en($sex_change_cost) ." [". plugin::EOMLink() ."], I will adjust your form.");
        $client->Message(15, "WARNING: You will disconnect immediately upon changing your sex.");
    }

    elsif ($text =~ /^RACECHANGE:(\d+)$/i) {
        if (plugin::SpendEOM($client, $race_change_cost)) {
            my $race_id = $1;
            my $races = get_races();
            if ($client->GetRace() != $race_id && exists $races->{$race_id}) {
                my $race_name = $races->{$race_id};
                quest::permarace($race_id);
            } else {
                $client->Message(13, "An error occurred. Unable to change race to ID $race_id.");
            }
        } else {
            quest::say("Sadly, $name, you do not have sufficient Echoes of Memory to properly anchor yourself for this change. Perhaps you will return later.");
        }
    }

    elsif ($text eq "SEXCHANGE") {
        if (plugin::SpendEOM($client, $sex_change_cost)) {
            quest::permagender(!$client->GetGender());
        } else {
            quest::say("Sadly, $name, you do not have sufficient Echoes of Memory to properly anchor yourself for this change. Perhaps you will return later.");
        }
    }

    elsif ($client->GetBucket("namechange_active")) {
        my @banlist = (
            'asshole', 'dick', 'bastard', 'whore', 'slut',
            'fag', 'dyke', 'cock', 'pussy', 
            'nigger', 'chink', 'spic', 'gook', 'kike', 'faggot', 'queer', 'tranny',
            'twat', 'wanker', 'prick', 'jizz', 'sperm', 'orgasm',
            'rape', 'molest', 'abuse', 'grope', 'murder', 'kill', 'suicide', 'death',
            'drug', 'cocaine', 'heroin', 'meth', 
            'motherfucker', 'clit', 'bullshit', 'retard', 'retarded',
            'douchebag', 'shithead', 'fuckface', 'asshat', 'cumshot', 'dildo', 
            'masturbate', 'masturbation', 'nazi', 'hitler', 'satan', 'satanic',
            'incest', 'pedophile', 'pedo', 'snuff', 'asslick', 'rimjob', 'blowjob',
            'handjob', 'analsex', 'sodomize', 'sodomy', 'scum', 'prostitute', 
            'porn', 'erotic', 'hooker', 'stripper',
            'gangbang', 'threesome', 'sextoy', 'vibrator',
            'homo', 'lesbo', 'lesbian', 'gay', 
        );

        if (length(lc($text)) > 2) {
            my $contains_banned = 0;
            foreach my $banned (@banlist) {
                if (index($text, $banned) != -1) {
                    $contains_banned = 1;
                    last;
                }
            }

            if (!$contains_banned && $text =~ /^[a-zA-Z]+$/) {
                $text = ucfirst(lc($text));
                $client->DeleteBucket("namechange_active");
                quest::rename($text);
            }
        }
    }

}
}

sub get_races {
    return {
        1   => 'Human',
        2   => 'Barbarian',
        3   => 'Erudite',
        4   => 'Wood Elf',
        5   => 'High Elf',
        6   => 'Dark Elf',
        7   => 'Half Elf',
        8   => 'Dwarf',
        9   => 'Troll',
        10  => 'Ogre',
        11  => 'Halfling',
        12  => 'Gnome',
        128 => 'Iksar',
        130 => 'Vah Shir',
        330 => 'Froglok',
    };
}
