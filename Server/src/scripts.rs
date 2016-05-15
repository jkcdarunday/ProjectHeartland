// Iron crates
extern crate iron;

// Database crates
extern crate r2d2;
extern crate r2d2_redis;
extern crate redis;


// Standard library functions
use std::io::prelude::*;
use std::fs::File;
use std::collections::HashMap;

// Database dependencies
use redis::Script;

// Iron dependencies
use iron::typemap::Key;

// Persistent Scripts
pub struct Scripts;
impl Key for Scripts { type Value = HashMap<String, Script>; }

pub fn get_scripts() -> HashMap<String, Script>{
    let mut scripts = HashMap::new();
    let filenames = vec![
        "student_schedule", "student_schedule_enlist", "student_schedule_cancel",
        "student_waitlist_enlist", "student_waitlist_cancel", "student_waitlist_position",
        "subject_waitlist_count", "subject_slots",
        "auth_login", "auth_logout", "auth_register"
     ];

    for file in filenames {
        let mut script = String::new();
        let filename = format!("lua/{}.lua", file);
        println!("Loading {}", filename);
        File::open(filename).unwrap().read_to_string(&mut script).unwrap();

        scripts.insert(file.to_string(), Script::new(&script));
    }

    return scripts;
}
