// Iron crates
extern crate iron;
extern crate mount;
extern crate persistent;
extern crate urlencoded;

#[macro_use]
extern crate router;

// Database crates
extern crate r2d2;
extern crate r2d2_redis;
extern crate redis;
// extern crate r2d2_mysql
// extern crate mysql_simple

extern crate rustc_serialize;

// Auth crates
extern crate uuid;
extern crate crypto;

// Iron dependencies
use mount::Mount;

use persistent::Read;

use iron::middleware::AfterMiddleware;
use iron::prelude::*;
use iron::headers::*;
use iron::method::*;

// Handler module
mod handler;

// Database module
mod database;

// Script module
mod scripts;

// Shared pools
use database::RedisPool;

// Shared scripts
use scripts::Scripts;

struct CrossOrigin;
impl AfterMiddleware for CrossOrigin {
    fn after(&self, _: &mut Request, mut res: Response) -> IronResult<Response> {
        res.headers.set(AccessControlAllowOrigin::Any);
        res.headers.set(AccessControlAllowMethods(vec![Get, Put, Post, Delete]));
        Ok(res)
    }
}

fn main(){
    let student_router = router!(
        get "/schedule" => handler::Enlisted::get,
        put "/schedule" => handler::Enlisted::put,
        delete "/schedule" => handler::Enlisted::del,

        get "/waitlist" => handler::Waitlist::get,
        put "/waitlist" => handler::Waitlist::put,
        delete "/waitlist" => handler::Waitlist::del,

        get "/profile" => handler::Student::get,
        put "/create" => handler::Student::put
    );

    let auth_router = router!(
        post "/login" => handler::Auth::post,
        delete "/logout" => handler::Auth::del,
        put "/register/:student_number" => handler::Auth::put
    );

    let subject_router = router!(
        get "/slots" => handler::Subject::get,
        put "/create" => handler::Subject::put
    );

    let admin_router = router!(
        post "/import_subjects" => handler::Admin::import_subjects,
        post "/import_students" => handler::Admin::import_students,
        post "/create" => handler::Admin::create_admin,
    );

    println!("Connecting to database..");
    let redis_db = database::redis_connect("redis://127.0.0.1", 512);
    println!("Done.");

    println!("Loading scripts from ./lua/..");
    let shared_scripts = scripts::get_scripts();
    println!("Done.");

    let mut mount = Mount::new();
    mount.mount("/student/", student_router);
    mount.mount("/auth/", auth_router);
    mount.mount("/subject/", subject_router);
    mount.mount("/admin/", admin_router);

    let mut chain = Chain::new(mount);
    chain.link(Read::<RedisPool>::both(redis_db));
    chain.link(Read::<Scripts>::both(shared_scripts));
    chain.link_after(CrossOrigin);

    Iron::new(chain).listen_with("0.0.0.0:3000", 512, iron::Protocol::Http, None).unwrap();
    println!("Started listening.");
}
