// Iron crates
extern crate iron;
extern crate mount;

#[macro_use]
extern crate router;

// Database dependencies
//extern crate redis
//extern crate mysql_simple
//r2d2?

// Iron dependencies
use mount::Mount;
use iron::Iron;

// Handler module
mod handler;

fn main(){
    let mut mount = Mount::new();

    let student_router = router!(
        get "/schedule" => handler::Enlisted::get,
        put "/schedule" => handler::Enlisted::put,
        delete "/schedule" => handler::Enlisted::del,

        get "/waitlist" => handler::Waitlist::get,
        put "/waitlist" => handler::Waitlist::put,
        delete "/waitlist" => handler::Waitlist::del
    );

    let auth_router = router!(
        post "/login" => handler::Auth::post,
        delete "/logout/:sid" => handler::Auth::del,
    );

    let subject_router = router!(
        get "/:subject" => handler::Subject::get
    );

    mount.mount("/student/", student_router);
    mount.mount("/auth/", auth_router);
    mount.mount("/subjects/", subject_router);

    Iron::new(mount).listen_with("0.0.0.0:3000", 4096, iron::Protocol::Http, None).unwrap();
}
